// @ts-nocheck
import { conflux } from "hardhat";

async function main() {
  const [signer] = await conflux.getSigners();
  console.log(`signer address is: `, signer.address);

  const admin_contract = conflux.InternalContract("AdminControl");

  const CONTRACTS = [];

  CONTRACTS.map(async (c, i) => {
    console.log("destroying...", i);

    // to kill the contract
    await admin_contract
      .destroy(c)
      .sendTransaction({
        from: signer,
      })
      .executed();

    console.log("destroyed contract: ", c);
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
