//Kovan test Info
//Oracle: 0xFfC4e227f9b033b752BCcc2241F8eCD892bE9D3c
// Link: 0xa36085F69e2889c224210F603D836748e7dC0088
//Current Weather JobId: 970382f6a16f480e9b2f2e16ee8ef6a1


const hre = require("hardhat");

async function main() {

  const Factory = await hre.ethers.getContractFactory("Betting");
  const bettingContract = await Factory.deploy("0xa36085F69e2889c224210F603D836748e7dC0088");

  await bettingContract.deployed();

  console.log("BettingContract deployed to:", bettingContract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
