import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();
import { HardhatUserConfig } from "hardhat/types";

import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-ethers";
// import "@typechain/hardhat";
import "hardhat-abi-exporter";

// npx hardhat verify 0xB5C15C64E54b38CC3367682A1A1675E987678028 --constructor-args args.js
// TODO: reenable solidity-coverage when it works
// import "solidity-coverage";

const ACCOUNT_PRIVATE_KEY = process.env.ACCOUNT_PRIVATE_KEY!; // well known private key
const BINANCE_API_KEY = process.env.BINANCE_API_KEY;
const INFURA_KOVAN = process.env.INFURA_KOVAN;
const ALCHEMY_KEY = process.env.ALCHEMY_KEY;

const config: HardhatUserConfig = {
  defaultNetwork: "mainnet",
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
      url: "https://speedy-nodes-nyc.moralis.io/7692f1448b78feec70571765/bsc/mainnet",
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
      url: `https://rinkeby.infura.io/v3/${INFURA_KOVAN}`,
      accounts: [ACCOUNT_PRIVATE_KEY],
    },
    kovan: {
      url: `https://kovan.infura.io/v3/${INFURA_KOVAN}`,
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
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.4",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.7",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: BINANCE_API_KEY,
  },
};

export default config;
