//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.9;
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Betting is Ownable, ChainlinkClient {
    using Chainlink for Chainlink.Request;
    uint256 public volume;
    uint256 public result;
    uint256 public oddsAbove;
    uint256 public oddsBelow;
    uint256 winnings = 0 wei;
    uint256 bettingPeriod = block.timestamp + 7 days;
    uint256 callTimestamp;
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    string public city;

    struct User {
        address id;
        uint256 guess;
        bool hasGuessed;
    }
    mapping(address => User) users;
    uint256[] guessValues;

    address[] usersWhoHaveVoted;

    event winnerPayed(address indexed winner, uint256 amount);

    constructor() {
        setPublicChainlinkToken(); //call on kovan testnet
        oracle = 0xbe79b86e93d09d6dda636352a06491ec8e7bdf12;
        jobId = "93b72982721945268cf3ba75894f773e";
        fee = 100000000000000000; //0.1 LINK
    }

    function requestWeatherTemperature(string memory _city) public {
        Chainlink.Request memory request = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillWeatherTemperature.selector
        );
        request.add("city", _city);
        sendChainlinkRequestTo(oracle, request, fee);
    }

    function fulfillWeatherTemperature(bytes32 _requestId, uint256 _result)
        public
        recordChainlinkFulfillment(_requestId)
    {
        result = _result;
    }

    function setUserGuess(uint256 _guess, string memory _city) public payable {
        require(!users[msg.sender].hasGuessed, "User already guessed!");
        require(block.timestamp < bettingPeriod, "The betting period is over.");
        require(msg.value == 100 wei, "Need to bet the minimum to play.");
        city = _city; //we will assume users are just guessing the weather for one city for now, put here in case we want to change later
        User memory user = User(msg.sender, _guess, true);
        usersWhoHaveVoted.push(msg.sender);
        guessValues.push(_guess);
        winnings += msg.value;
        // this guy needs to be called periodically to adjust odds, ideally by keepers but I have just set it to fire off every hour or so after a guess
        if (block.timestamp - callTimestamp > 1 hours) {
            requestWeatherTemperature(_city);

            callTimestamp = block.timestamp;
        }
    }

    function setOdds() public {
        require(guessValues.length > 0, "People need to have guessed");
        uint256 aboveValueGuesses = 0;
        uint256 belowValueGuesses = 0;
        uint256 equalValueGuesses = 0;
        for (uint256 i = 0; i < guessValues.length; i++) {
            if (guessValues[i] < result) {
                belowValueGuesses++;
            } else if (guessValues[i] > result) {
                aboveValueGuesses++;
            } else {
                equalValueGuesses++;
            }
        }
        //odds are multiplied by 10**9 for fixed point math, front end can convert them back to decimals
        oddsAbove = ((aboveValueGuesses * (10**9)) /
            (belowValueGuesses + equalValueGuesses));
        oddsBelow = ((belowValueGuesses * (10**9)) /
            (aboveValueGuesses + equalValueGuesses));
    }

    function resetLottery() public onlyOwner {
        for (uint256 i = 0; i < usersWhoHaveVoted.length; i++) {
            delete users[usersWhoHaveVoted[i]];
            delete guessValues[i];
        }
        delete usersWhoHaveVoted;
        delete guessValues;
    }

    function getPrizeMoney() public view returns (uint256) {
        return (winnings * 99) / 100; //we keep the 1% fee
    }

    //this function establishes the final update that will be used to calculate the winner
    function finalResult() private onlyOwner {
        require(
            block.timestamp > bettingPeriod,
            "can only call after users bet"
        );
        requestWeatherTemperature(city);
    }

    function getNumberOfWinners() internal view returns (uint256) {
        uint256 count = 0;

        for (uint256 i = 0; i < guessValues.length; i++) {
            if (guessValues[i] == result) {
                count++;
            }
        }
        return count;
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
        require(winnings >= 0 wei, "No bets placed");

        address[] memory winners = getWinners();
        require(winners.length > 0, "No winners this round");

        uint256 amountPerWinner = (winnings / winners.length);

        for (uint256 i = 0; i < winners.length; ++i) {
            (bool sent, bytes memory data) = payable(winners[i]).call{
                value: amountPerWinner
            }("");
            emit winnerPayed(winners[i], amountPerWinner);
        }
    }
}