// @ts-nocheck
import { conflux } from "hardhat";
import { NAMEWRAPPER, STORE, CNSMARKETPLACE } from "./config";

async function main() {
  const [signer] = await conflux.getSigners();
  console.log(`signer address is: `, signer.address);

  const CNSUtils = await conflux.getContractFactory("CNSUtils");

  console.log("deploy CNSUtils contract");

  const receipt = await CNSUtils.constructor(STORE, CNSMARKETPLACE, NAMEWRAPPER)
    .sendTransaction({
      from: signer.address,
    })
    .executed();

  console.log(
    `Contract deploy ${receipt.outcomeStatus === 0 ? "Success" : "Failed"}`
  );

  const contractAddress = receipt.contractCreated;
  console.log(`New deployed contract address: ${contractAddress}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
