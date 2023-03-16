// @ts-nocheck
import { conflux } from "hardhat";

async function main() {
  const [signer] = await conflux.getSigners();
  console.log(`signer address is: `, signer.address);

  const cnsAddr = "cfxtest:acaawgw9jg2jr293jx5sh0pmkfuer1a7pugpdnza6a";
  const storeAddr = "cfxtest:acguxjbrxanteh5p3gpv97af73znw89kxejm2rc85r";
  const vaultAddr = "cfxtest:aanuezhds5f226se3gr309zuyxr4g32vcpceec0uer";
  const nameWrapperAddr = "cfxtest:acapc3y2j7atme3bawvaex18hs36tn40uu5h6j3mtu";
  const ROLE_CALL =
    "0x706a455ca44ffc9f46e1c567fb1a4fdf73956f8e912065b7c4c6af237e247d9c";

  console.log("initial cns marketplace");

  const cns = await conflux.getContractAt("CNSMarketplace", cnsAddr);

  // update store
  console.log("update store");
  await cns
    .updateStore(storeAddr)
    .sendTransaction({
      from: signer.address,
    })
    .executed();

  console.log("update vault");
  // update vault
  await cns
    .updateVault(vaultAddr)
    .sendTransaction({
      from: signer.address,
    })
    .executed();

  console.log("update whitelist");
  // update whitelist
  await cns
    .updateWhitelist(nameWrapperAddr, true)
    .sendTransaction({
      from: signer.address,
    })
    .executed();

  const store = await conflux.getContractAt("Store", storeAddr);

  // grant call role to cns marketplace
  console.log("grant cns marketplace with call role");
  await store
    .grantRole(ROLE_CALL, cnsAddr)
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
