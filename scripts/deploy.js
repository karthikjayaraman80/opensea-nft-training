const { task } = require("hardhat/config");
const { getAccount, getEnvVariable } = require("./helpers");



const network = getEnvVariable("NETWORK");

// OpenSea proxy registry addresses for rinkeby and mainnet.
let proxyRegistryAddress = "";
if (network === 'rinkeby') {
    proxyRegistryAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";
} else {
    proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
}


task("check-balance", "Prints out the balance of your account").setAction(async function (taskArguments, hre) {
    const account = getAccount();
    console.log(`Account balance for ${account.address}: ${await account.getBalance()}`);
});

task("deploy-nft", "Deploys the NFT.sol contract")
  .addParam("name","The name of the Contract")
  .addParam("symbol","The symbol for the Contract")
  .addParam("baseuri","The base URI for the Contract")
  .setAction(async function (taskArguments, hre) {

    const nftContractFactory = await hre.ethers.getContractFactory("NFT", getAccount());
    const nft = await nftContractFactory.deploy(taskArguments.name, taskArguments.symbol, taskArguments.baseuri, proxyRegistryAddress);
    console.log(`Contract deployed to address: ${nft.address}`);
   
});

task("deploy-factory", "Deploys the NFTFactory.sol contract")
  .setAction(async function (taskArguments, hre) {
    const nftAddress = getEnvVariable("NFT_CONTRACT_ADDRESS");
    const nftFactoryContractFactory = await hre.ethers.getContractFactory("NFTFactory", getAccount());
    const nftFactory = await nftFactoryContractFactory.deploy(proxyRegistryAddress, nftAddress);
    console.log(`NFT Factory Contract deployed to address: ${nftFactory.address}`);
});

task("deploy-all", "Deploys the NFT.sol and NFTFactory.sol contract")
  .addParam("name","The name of the Contract")
  .addParam("symbol","The symbol for the Contract")
  .addParam("baseuri","The base URI for the Contract")
  .setAction(async function (taskArguments, hre) {

    const nftContractFactory = await hre.ethers.getContractFactory("NFT", getAccount());
    const nft = await nftContractFactory.deploy(taskArguments.name, taskArguments.symbol, taskArguments.baseuri, proxyRegistryAddress);
    console.log(`NFT Contract deployed to address: ${nft.address}`);
   
    const nftFactoryContractFactory = await hre.ethers.getContractFactory("NFTFactory", getAccount());
    const nftFactory = await nftFactoryContractFactory.deploy(proxyRegistryAddress, nft.address);
    console.log(`NFT Factory Contract deployed to address: ${nftFactory.address}`);
});



