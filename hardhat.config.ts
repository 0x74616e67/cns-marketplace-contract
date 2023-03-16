import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-conflux";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    // conflux testnet
    ct: {
      url: "https://test.confluxrpc.com",
      accounts: [
        "49365cc6377e5061abc935bf7ae9056ea568e4322ddb7babb5cc64abf8434dc5",
      ],
      chainId: 1,
    },
    // TODO conflux mainnet
    // cm: {},
  },
};

export default config;
