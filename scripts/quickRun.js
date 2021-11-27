
require("dotenv").config();
const BettingContract = require("../artifacts/contracts/Betting.sol/Betting.json");
var ethers = require('ethers');

var provider = new ethers.providers.AlchemyProvider('maticmum');
var address  = '0xA860Ce84D6d481Eb6129f278866495b515d0E037';
var abi = BettingContract.abi;
var privateKey = process.env.PRIVATE_KEY;
var wallet = new ethers.Wallet(privateKey, provider);
var bettingContract = new ethers.Contract(address, abi, wallet);

const overrides = {
    value: ethers.utils.parseEther('0.000000000000000100')
}

//var sendPromise = bettingContract.placeBet(1, overrides);
var sendPromise = bettingContract.getBet("0x014Da1D627E6ceB555975F09D26B048644382Ac6");

sendPromise.then(function(transaction){
  console.log(transaction);
});