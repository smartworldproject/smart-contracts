import { config as dotEnvConfig } from "dotenv";
import { HardhatUserConfig } from "hardhat/types";
dotEnvConfig();

import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "@typechain/hardhat";
import "hardhat-abi-exporter";

// npx hardhat verify address --constructor-args args.js
// TODO: reenable solidity-coverage when it works
// import "solidity-coverage";

const ACCOUNT_PRIVATE_KEY = process.env.ACCOUNT_PRIVATE_KEY!; // well known private key
const MORALIS_API_KEY = process.env.MORALIS_API_KEY;
const BINANCE_API_KEY = process.env.BINANCE_API_KEY;
const INFURA_API_KEY = process.env.INFURA_API_KEY;
const ALCHEMY_KEY = process.env.ALCHEMY_KEY;

const config: HardhatUserConfig = {
  defaultNetwork: "testnet",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    hardhat: {
      forking: {
        url: `https://eth-mainnet.alchemyapi.io/v2/${ALCHEMY_KEY}`,
        blockNumber: 11095000,
      },
    },
    moralis: {
      url: `https://speedy-nodes-nyc.moralis.io/${MORALIS_API_KEY}/bsc/mainnet`,
      chainId: 56,
      gasPrice: 20000000000,
      accounts: [ACCOUNT_PRIVATE_KEY],
    },
    testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [ACCOUNT_PRIVATE_KEY],
    },
    mainnet: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      gasPrice: 20000000000,
      accounts: [ACCOUNT_PRIVATE_KEY],
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [ACCOUNT_PRIVATE_KEY],
    },
    // deprecated
    ropsten: {
      url: `https://ropsten.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [ACCOUNT_PRIVATE_KEY],
    },
    kovan: {
      url: `https://kovan.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [ACCOUNT_PRIVATE_KEY],
    },
    coverage: {
      url: "http://127.0.0.1:8555", // Coverage launches its own ganache-cli client
    },
  },

  abiExporter: {
    path: "./data/abi",
    clear: true,
    flat: true,
    only: [":ERC20$"],
    spacing: 2,
  },
  solidity: {
    compilers: [
      {
        version: "0.8.7",
        settings: {
          optimizer: {
            enabled: false,
            runs: 200,
          },
        },
      },
    ],
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    // apiKey: process.env.ETHERSCAN_API_KEY,
    apiKey: BINANCE_API_KEY,
  },
};

export default config;
