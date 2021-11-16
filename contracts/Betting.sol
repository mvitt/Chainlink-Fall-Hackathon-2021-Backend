//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.10;
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./User.sol";
import "./GuessIs.sol";

contract Betting is Ownable, ChainlinkClient {
    using Chainlink for Chainlink.Request;

    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    uint256 public result;
    string public city;
    uint256 private bettingPeriod = block.timestamp + 7 days;
    address payable public contractAddress;
    address[] public usersWhoHaveVoted;
    mapping(address => User) public users;

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

    function placeBet(uint256 _guess) public payable {
        require(!users[msg.sender].hasGuessed, "User already guessed!");
        require(block.timestamp < bettingPeriod, "The betting period is over.");

        User memory user = User(msg.sender, _guess, true, GuessIs.EMPTY, msg.value, 0);
        usersWhoHaveVoted.push(msg.sender);

        users[msg.sender] = user;
    }

    function clearBets() public onlyOwner {
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
        clearBets();
    }

    function payWinners() private {
        require(contractAddress.balance >= 0 wei, "No bets placed");

        address[] memory winners = sortPlayersByBetsAndGetWinners();
        require(winners.length > 0, "No winners this round");


        for (uint256 i = 0; i < winners.length; ++i) {

            uint256 amountForWinner = (users[winners[i]].winningPercentage / 100) * getPrizeMoney();

            (bool sent, bytes memory data) = payable(winners[i]).call{value: amountForWinner}("");
            emit WinnerPayed(winners[i], amountForWinner);
        }
    }

    function sortPlayersByBetsAndGetWinners() internal returns (address[] memory) {

        uint256 totalAmountBetByWinners = 0;
        address[] memory addressesOfWinners;
        uint256 winnerCount = 0;

        for (uint256 i = 0; i < usersWhoHaveVoted.length; i++) {
            if (users[usersWhoHaveVoted[i]].guess == result){
                users[usersWhoHaveVoted[i]].guessIs = GuessIs.EQUAL_TO;
                totalAmountBetByWinners = totalAmountBetByWinners + users[usersWhoHaveVoted[i]].amountBet;
                addressesOfWinners[winnerCount] = users[usersWhoHaveVoted[i]].id;
                winnerCount++;
                continue;
            } else if (users[usersWhoHaveVoted[i]].guess > result){
                users[usersWhoHaveVoted[i]].guessIs = GuessIs.ABOVE;
                continue;
            } else if (users[usersWhoHaveVoted[i]].guess < result){
                users[usersWhoHaveVoted[i]].guessIs = GuessIs.BELOW;
                continue;
            }
        }

        for (uint256 i = 0; i < addressesOfWinners.length; i++) {    
            users[addressesOfWinners[i]].winningPercentage = (users[addressesOfWinners[i]].amountBet / totalAmountBetByWinners) * 100;
        }

        return addressesOfWinners;
    }
}
