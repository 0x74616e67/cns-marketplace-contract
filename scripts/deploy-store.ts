// @ts-nocheck
import { conflux } from "hardhat";

async function main() {
  const [signer] = await conflux.getSigners();

  console.log(`signer address is: `, signer.address);

  const Store = await conflux.getContractFactory("Store");

  console.log("deploy store contract");

  const receipt = await Store.constructor()
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
