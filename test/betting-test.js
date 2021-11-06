const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Betting Contract", function () {
  it("Should deploy the contracrt and return an address", async function () {
    const Factory = await ethers.getContractFactory("Betting");
    const contract = await Factory.deploy();
    await contract.deployed();

    expect(contract.address).is.not.null;
  });
});
