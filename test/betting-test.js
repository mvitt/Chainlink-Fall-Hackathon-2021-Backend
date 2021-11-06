const { expect } = require("chai");
const { ethers } = require("hardhat");
const { FakeContract, smock } = require('@defi-wonderland/smock');

describe("Betting Contract", function () {
  it("Should deploy the contracrt and return an address", async function () {
    const Factory = await ethers.getContractFactory("Betting");
    console.log("BettingContract deployed to:");
    //kovan values
    const contract = await Factory.deploy("0xbe79b86e93d09d6dda636352a06491ec8e7bdf12", "93b72982721945268cf3ba75894f773e", 0.1 * 10 ** 18);
    await contract.deployed();
    console.log("BettingContract deployed to:", contract.address);

    expect(contract.address).is.not.null;
  });
});
