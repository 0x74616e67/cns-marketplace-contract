import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-conflux";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    // conflux testnet
    ct: {
      url: "https://test.confluxrpc.com",
      accounts: [""],
      chainId: 1,
    },
    // TODO conflux mainnet
    // cm: {},
  },
};

export default config;
