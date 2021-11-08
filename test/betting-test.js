const { expect } = require("chai");
const { ethers } = require("hardhat");
const { deployContract, deployMockContract, MockProvider } = require("ethereum-waffle");
const BettingContract = require("../artifacts/contracts/Betting.sol/Betting.json");


describe("Betting Contract", () => {

  const provider = new MockProvider();
  const [wallet, walletTo] = provider.getWallets();

  let contract;

  beforeEach(async () => {
    contract = await deployMockContract(wallet, BettingContract.abi);
  });

  it('is a proper address', async () => {
    console.log(contract.address);
    expect(contract.address).to.be.properAddress;
  });

});
