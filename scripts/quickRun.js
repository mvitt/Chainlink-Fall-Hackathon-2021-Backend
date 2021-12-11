
require("dotenv").config();
const BettingContract = require("../artifacts/contracts/Betting.sol/Betting.json");
var ethers = require('ethers');

var provider = new ethers.providers.AlchemyProvider('maticmum');
var address  = process.env.BETTING_ADDRESS;
var abi = BettingContract.abi;
var privateKey = process.env.PRIVATE_KEY;
var wallet = new ethers.Wallet(privateKey, provider);
var bettingContract = new ethers.Contract(address, abi, wallet);

const overrides = {
    value: ethers.utils.parseEther('0.000000000000000100')
}

//var sendPromise = bettingContract.requestTemperatureFor("0xea435393E8EA5d007F838CE9fd5b6Fa2c66A5A8e", "dce7c3107f314c61a0c70499bb9a1709", "Chicago", 1);
// var sendPromise = bettingContract.temperaturePrediction();
var sendPromise = bettingContract.actualTemperature();
// var sendPromise = bettingContract.placeBet(1, overrides);
// var sendPromise = bettingContract.getBet("0x014Da1D627E6ceB555975F09D26B048644382Ac6");


sendPromise.then(function(transaction){
//   console.log(transaction);
  console.log(ethers.BigNumber.from(transaction).toNumber()); //For converting hex of temp to a number
});