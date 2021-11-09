//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.10;
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./User.sol";

contract Betting is Ownable, ChainlinkClient {
    using Chainlink for Chainlink.Request;
    uint256 public result;
    uint256 public oddsAbove;
    uint256 public oddsBelow;
    uint256 private bettingPeriod = block.timestamp + 7 days;
    uint256 private callTimestamp;
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    string public city;

    address payable public contractAddress;

    mapping(address => User) public users;

    address[] public usersWhoHaveVoted;

    event WinnerPayed(address indexed winner, uint256 amount);

    constructor() {
        setPublicChainlinkToken(); //call on kovan testnet
        oracle = 0xAA1DC356dc4B18f30C347798FD5379F3D77ABC5b;
        jobId = "235f8b1eeb364efc83c26d0bef2d0c01";
        fee = 0.1 * 10 ** 18; //0.1 LINK
        contractAddress = payable(address(this));
        //Set Chicago as the default city
        setCity("Chicago");
    }

    function requestWeatherTemperature() public {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfillWeatherTemperature.selector);
        request.add("city", city);
        sendChainlinkRequestTo(oracle, request, fee);
    }

    function fulfillWeatherTemperature(bytes32 _requestId, uint256 _result) public recordChainlinkFulfillment(_requestId) {
        result = _result;
    }

    function setCity(string memory _city) public onlyOwner {
        city = _city;
    }

    function setUserGuess(uint256 _guess) public payable {
        require(!users[msg.sender].hasGuessed, "User already guessed!");
        require(block.timestamp < bettingPeriod, "The betting period is over.");

        User memory user = User(msg.sender, _guess, msg.value, true);
        usersWhoHaveVoted.push(msg.sender);

        users[msg.sender] = user;

        // this guy needs to be called periodically to adjust odds, ideally by keepers but I have just set it to fire off every hour or so after a guess
        if (block.timestamp - callTimestamp > 1 hours) {
            requestWeatherTemperature();

            callTimestamp = block.timestamp;
        }
    }

    function setOdds() public {
        require(usersWhoHaveVoted.length > 0, "People need to have guessed");

        uint256 aboveValueGuesses = 0;
        uint256 belowValueGuesses = 0;
        uint256 equalValueGuesses = 0;
        User[] memory players = getAllPlayers();
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i].guess < result) {
                belowValueGuesses++;
            } else if (players[i].guess > result) {
                aboveValueGuesses++;
            } else {
                equalValueGuesses++;
            }
        }
        //odds are multiplied by 10**9 for fixed point math, front end can convert them back to decimals
        oddsAbove = ((aboveValueGuesses * (10**9)) / (belowValueGuesses + equalValueGuesses));
        oddsBelow = ((belowValueGuesses * (10**9)) / (aboveValueGuesses + equalValueGuesses));
    }

    function resetLottery() public onlyOwner {
        for (uint256 i = 0; i < usersWhoHaveVoted.length; i++) {
            delete users[usersWhoHaveVoted[i]];
        }
        delete usersWhoHaveVoted;
    }

    function getPrizeMoney() public view returns (uint256) {
        return (contractAddress.balance * 99) / 100; //we keep the 1% fee
    }

    //this function establishes the final update that will be used to calculate the winner
    function finalResult() private onlyOwner {
        require(block.timestamp > bettingPeriod, "can only call after users bet");
        requestWeatherTemperature();
        payWinners();
        resetLottery();
    }

    function getNumberOfWinners() internal view returns (uint256) {
        uint256 count = 0;

        for (uint256 i = 0; i < usersWhoHaveVoted.length; i++) {
            if (users[usersWhoHaveVoted[i]].guess == result){
                count++;
            }
        }
        return count;
    }

    function getAllPlayers() internal view returns (User[] memory) {
        User[] memory players = new User[](usersWhoHaveVoted.length); 

        for (uint256 i = 0; i < usersWhoHaveVoted.length; i++) {
            players[i] = users[usersWhoHaveVoted[i]];
        }
        return players;
    }

    function getWinners() internal view returns (address[] memory) {
        uint256 count = 0;
        address[] memory winners = new address[](getNumberOfWinners());

        for (uint256 i = 0; i < usersWhoHaveVoted.length; i++) {
            if (users[usersWhoHaveVoted[i]].guess == result) {
                winners[count] = users[usersWhoHaveVoted[i]].id;
                count++;
            }
        }

        return winners;
    }

    function payWinners() private {
        require(contractAddress.balance >= 0 wei, "No bets placed");

        address[] memory winners = getWinners();
        require(winners.length > 0, "No winners this round");

        uint256 amountPerWinner = (contractAddress.balance / winners.length);

        for (uint256 i = 0; i < winners.length; ++i) {
            (bool sent, bytes memory data) = payable(winners[i]).call{value: amountPerWinner}("");
            emit WinnerPayed(winners[i], amountPerWinner);
        }
    }
}
