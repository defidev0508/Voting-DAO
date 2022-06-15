import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import * as dotenv from "dotenv";
import "hardhat-docgen";
import "hardhat-gas-reporter";
import { HardhatUserConfig } from "hardhat/config";
import "solidity-coverage";
import "./tasks/index.ts";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.4",
  docgen: {
    path: "./docs",
    clear: true,
    runOnCompile: true,
  },
  networks: {
    rinkeby: {
      url: process.env.RINKEBY_URL,
      accounts: [<string>process.env.PRIVATE_KEY],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;
