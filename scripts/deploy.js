//Kovan Test Info
//Oracle: 0xFfC4e227f9b033b752BCcc2241F8eCD892bE9D3c
// Link: 0xa36085F69e2889c224210F603D836748e7dC0088
//Current Weather JobId: 970382f6a16f480e9b2f2e16ee8ef6a1
//Five Day Weather JobId: 0db437765a2948c09d4c3939d772a497

//Mumbai Test Info
//Oracle: 0xea435393E8EA5d007F838CE9fd5b6Fa2c66A5A8e
// Link: 0x326C977E6efc84E512bB9C30f76E30c160eD06FB
//Current Weather JobId: dce7c3107f314c61a0c70499bb9a1709
//Five Day Weather JobId: 97bffeec72a24c4f9d29d36e9662ed3b


const hre = require("hardhat");

async function main() {

  const Factory = await hre.ethers.getContractFactory("Betting");
  const bettingContract = await Factory.deploy("0x326C977E6efc84E512bB9C30f76E30c160eD06FB");

  await bettingContract.deployed();

  console.log("BettingContract deployed to:", bettingContract.address);

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
