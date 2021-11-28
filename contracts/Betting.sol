//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.10;
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./User.sol";
import "./Bet.sol";
import "./WeatherType.sol";

contract Betting is AccessControl, ChainlinkClient {
    using Chainlink for Chainlink.Request;

    uint256 constant FEE = LINK_DIVISIBILITY / 10; //0.1 LINK  aka 0.1 * 10 ** 18; 

    uint256 public temperaturePrediction;
    uint256 public actualTemperature;
    uint256 private bettingPeriodClosedAt;
    address payable public contractAddress;
    address[] public usersWhoHaveVoted;
    mapping(address => User) public users;

    event WinnerPayed(address indexed winner, uint256 amount);

    constructor(address _link) {
        if (_link == address(0)){
            setPublicChainlinkToken();
        } else {
            setChainlinkToken(_link);
        }
        
        contractAddress = payable(address(this));
        bettingPeriodClosedAt = block.timestamp + 7 days;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        grantRole(DEFAULT_ADMIN_ROLE, 0x86bde469014a15e41C8638d0f9DC7E150bc44650);
    }

    modifier verifyBettingPeriodOpen() {
        require(block.timestamp < bettingPeriodClosedAt, "The betting period is open.");
        _;
    }

    modifier verifyBettingPeriodClosed() {
        require(block.timestamp > bettingPeriodClosedAt, "The betting period is over.");
        _;
    }

    function getTimeLeft() external view returns(uint256) {
        return (block.timestamp < bettingPeriodClosedAt) ? bettingPeriodClosedAt - block.timestamp : 0;
    }

    function requestTemperatureFor(address _oracle, string memory _jobId, string memory _city, WeatherType _type) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_type != WeatherType.EMPTY, "WeatherType must not be: EMPTY");
        bytes4 selector = (_type == WeatherType.PREDICTION) ? this.fulfillTemperaturePrediction.selector : this.fulfillActualTemperature.selector;
        Chainlink.Request memory request = buildChainlinkRequest(stringToBytes32(_jobId), address(this), selector);
        request.add("city", _city);
        sendChainlinkRequestTo(_oracle, request, FEE);
    }

    function fulfillTemperaturePrediction(bytes32 _requestId, uint256 _result) public recordChainlinkFulfillment(_requestId) {
        temperaturePrediction = _result;
    }

    function fulfillActualTemperature(bytes32 _requestId, uint256 _result) public recordChainlinkFulfillment(_requestId) {
        actualTemperature = _result;
    }

    function placeBet(Bet _bet) public payable verifyBettingPeriodOpen {
        require(!users[msg.sender].hasBet, "User already bet!");

        User memory user = User(msg.sender, _bet, true, msg.value, 0);
        usersWhoHaveVoted.push(msg.sender);
        users[msg.sender] = user;
    }

    function getAmountBetFor(address betterAddress) external view returns (uint256){
        return users[betterAddress].amountBet;
    }

    function hasBet(address betterAddress) external view returns (bool){
        return users[betterAddress].hasBet;
    }

    function getBetFor(address betterAddress) external view returns (Bet){
        return users[betterAddress].bet;
    }
    function fetchAllBetters() external view returns (address[] memory) {
        return usersWhoHaveVoted;
    }

    function clearBets() private {
        for (uint256 i = 0; i < usersWhoHaveVoted.length; i++) {
            delete users[usersWhoHaveVoted[i]];
        }
        delete usersWhoHaveVoted;
    }

    function getPrizeMoney() public view returns (uint256) {
        return (contractAddress.balance * 99) / 100; //we keep the 1% FEE
    }

    function sortPlayersByBetsAndGetWinners() private returns (address[] memory) {
        Bet finalResultIs = Bet.EMPTY;
        uint256 totalAmountBetByWinners = 0;
        address[] memory addressesOfWinners;
        uint256 winnerCount = 0;

        if (actualTemperature > temperaturePrediction) {
            finalResultIs = Bet.OVER;
        } else if (actualTemperature < temperaturePrediction) {
            finalResultIs = Bet.UNDER;
        }

        for (uint256 i = 0; i < usersWhoHaveVoted.length; i++) {
            if (users[usersWhoHaveVoted[i]].bet == finalResultIs){
                totalAmountBetByWinners = totalAmountBetByWinners + users[usersWhoHaveVoted[i]].amountBet;
                addressesOfWinners[winnerCount] = users[usersWhoHaveVoted[i]].id;
                winnerCount++;
            }
        }

        for (uint256 i = 0; i < addressesOfWinners.length; i++) {    
            users[addressesOfWinners[i]].winningPercentage = (users[addressesOfWinners[i]].amountBet / totalAmountBetByWinners) * 100;
        }

        return addressesOfWinners;
    }

    function payWinners() private {
        require(contractAddress.balance >= 0 wei, "No bets placed");

        address[] memory winners = sortPlayersByBetsAndGetWinners();

        require(winners.length > 0, "No winners this round");

        for (uint256 i = 0; i < winners.length; i++) {

            uint256 amountForWinner = (users[winners[i]].winningPercentage / 100) * getPrizeMoney();

            payable(winners[i]).call{value: amountForWinner}("");

            emit WinnerPayed(winners[i], amountForWinner);
        }
    }

    function finalResult(address _oracle, string memory _jobId, string memory _city) public onlyRole(DEFAULT_ADMIN_ROLE) verifyBettingPeriodClosed {
        requestTemperatureFor(_oracle, _jobId, _city, WeatherType.ACTUAL);
        payWinners();
        clearBets();

        //Reset betting period for next cycle
        bettingPeriodClosedAt = block.timestamp + 7 days;
    }

    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
        return 0x0;
        }

        assembly { // solhint-disable-line no-inline-assembly
        result := mload(add(source, 32))
        }
  }
}
