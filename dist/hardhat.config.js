"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var dotenv_1 = require("dotenv");
dotenv_1.config();
require("@nomiclabs/hardhat-waffle");
require("@typechain/hardhat");
require("@nomiclabs/hardhat-etherscan");
// TODO: reenable solidity-coverage when it works
// import "solidity-coverage";
var INFURA_API_KEY = process.env.INFURA_API_KEY || "";
var RINKEBY_PRIVATE_KEY = process.env.RINKEBY_PRIVATE_KEY ||
    "0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3"; // well known private key
var ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
var config = {
    defaultNetwork: "hardhat",
    solidity: {
        compilers: [{ version: "0.6.0", settings: {} }],
    },
    networks: {
        hardhat: {},
        localhost: {},
        rinkeby: {
            url: "https://rinkeby.infura.io/v3/" + INFURA_API_KEY,
            accounts: [RINKEBY_PRIVATE_KEY],
        },
        coverage: {
            url: "http://127.0.0.1:8555", // Coverage launches its own ganache-cli client
        },
    },
    etherscan: {
        // Your API key for Etherscan
        // Obtain one at https://etherscan.io/
        apiKey: ETHERSCAN_API_KEY,
    },
};
exports.default = config;
