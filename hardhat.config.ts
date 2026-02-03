import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-ethers";

const config: HardhatUserConfig = {
  solidity: { compilers: [{ version: "0.8.17", settings: {} }] },
  networks: {
    hardhat: {},
  },
};

export default config;
