const opensea = require("opensea-js");
const OpenSeaPort = opensea.OpenSeaPort;
const Network = opensea.Network;
const RPCSubprovider = require("web3-provider-engine/subproviders/rpc");

const Web3ProviderEngine = require("web3-provider-engine");

const { task } = require("hardhat/config");
const { getAccount, getEnvVariable } = require("./helpers");
const network = getEnvVariable("NETWORK");

task("sell", "Sell Multiple NFTs")
  .addParam("number", "Number of NFT Tokens to sell")
  .setAction(async function (taskArguments, hre) {
    const infuraRpcSubprovider = new RPCSubprovider({
        //rpcUrl: "https://eth-" + network + ".alchemyapi.io/v2/" + getEnvVariable("ALCHEMY_KEY"),
        rpcUrl: "https://" + network + ".infura.io/v3/" + getEnvVariable("INFURA_KEY"),
    });
    const providerEngine = new Web3ProviderEngine();
    providerEngine.addProvider(infuraRpcSubprovider);
    providerEngine.start();

    const seaport = new OpenSeaPort(
    providerEngine,
    {
        networkName: network,
        //apiKey: API_KEY,
    },
    (arg) => console.log(arg)
    );
    const factoryAddress = getEnvVariable("NFT_FACTORY_ADDRESS");
    
    const sellOrders = await seaport.createFactorySellOrders({
        assets: [
            {
              tokenId: 0,
              tokenAddress: factoryAddress,
            },
          ],
        accountAddress: getEnvVariable("WALLET_ADDRESS"),
        startAmount: 0.01,
        numberOfOrders: taskArguments.number // Will create 100 sell orders in parallel batches to speed things up
      })
      console.log(
        `Successfully made ${sellOrders.length} fixed-price sell orders! ${sellOrders[0].asset.openseaLink}\n`
      );
 });
