// @ts-nocheck
import { conflux } from "hardhat";
import { NAMEWRAPPER, STORE, ROLE_CALL, UTIL, CNSMARKETPLACE } from "./config";

async function main() {
  const [signer] = await conflux.getSigners();
  console.log(`signer address is: `, signer.address);

  const store = await conflux.getContractAt("Store", STORE);

  // grant call role to cns marketplace
  console.log("grant namewrapper with call role");
  await store
    .grantRole(ROLE_CALL, NAMEWRAPPER)
    .sendTransaction({
      from: signer.address,
    })
    .executed();

  // grant call role to cns marketplace
  console.log("grant cnsmarketplace with call role");
  await store
    .grantRole(ROLE_CALL, CNSMARKETPLACE)
    .sendTransaction({
      from: signer.address,
    })
    .executed();

  // grant call role to cns utils
  console.log("grant CNSUtils with call role");
  await store
    .grantRole(ROLE_CALL, UTIL)
    .sendTransaction({
      from: signer.address,
    })
    .executed();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
