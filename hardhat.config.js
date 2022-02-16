/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 require('dotenv').config();
 require("@nomiclabs/hardhat-ethers");
 require("./scripts/deploy.js");
 require("./scripts/mint.js");
 require("@nomiclabs/hardhat-etherscan");
 
 const { ALCHEMY_KEY, ACCOUNT_PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;
 

 const { TASK_COMPILE_SOLIDITY_GET_SOLC_BUILD } = require("hardhat/builtin-tasks/task-names");
 const path = require("path");
 
 subtask(TASK_COMPILE_SOLIDITY_GET_SOLC_BUILD, async (args, hre, runSuper) => {
   if (args.solcVersion === "0.8.1") {
    const compilerPath = path.join(__dirname, "soljson-v0.8.1.js");
 
     return {
       compilerPath,
       isSolcJs: true, // if you are using a native compiler, set this to false
       version: args.solcVersion,
       // this is used as extra information in the build-info files, but other than
       // that is not important
       longVersion: "0.8.1"
     }
   }
 
   // we just use the default subtask if the version is not 0.8.5
   return runSuper();
 })


 module.exports = {
    solidity: "0.8.1",
    defaultNetwork: "rinkeby",
    networks: {
     hardhat: {},
     rinkeby: {
       url: `https://eth-rinkeby.alchemyapi.io/v2/${ALCHEMY_KEY}`,
       accounts: [`0x${ACCOUNT_PRIVATE_KEY}`]
     },
     ethereum: {
       chainId: 1,
       url: `https://eth-mainnet.alchemyapi.io/v2/${ALCHEMY_KEY}`,
       accounts: [`0x${ACCOUNT_PRIVATE_KEY}`]
     },
   },
   etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
 }
