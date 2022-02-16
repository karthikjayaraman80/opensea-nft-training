const { task } = require("hardhat/config");
const { getAccount } = require("./helpers");


task("check-balance", "Prints out the balance of your account").setAction(async function (taskArguments, hre) {
    const account = getAccount();
    console.log(`Account balance for ${account.address}: ${await account.getBalance()}`);
});

task("deploy", "Deploys the NFT.sol contract")
  .addParam("name","The name of the Contract")
  .addParam("symbol","The symbol for the Contract")
  .addParam("baseURI","The base URI for the Contract")
  .setAction(async function (taskArguments, hre) {
    const nftContractFactory = await hre.ethers.getContractFactory("NFT", getAccount());
    const nft = await nftContractFactory.deploy(taskArguments.name, taskArguments.symbol, taskArguments.baseURI);
    console.log(`Contract deployed to address: ${nft.address}`);
});