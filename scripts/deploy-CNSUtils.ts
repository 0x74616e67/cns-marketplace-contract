// @ts-nocheck
import { conflux } from "hardhat";

const STORE_ADDR = "cfxtest:acguxjbrxanteh5p3gpv97af73znw89kxejm2rc85r";
const CNSMARKETPLACE_ADDR =
  "cfxtest:acaawgw9jg2jr293jx5sh0pmkfuer1a7pugpdnza6a";
const ROLE_CALL =
  "0x706a455ca44ffc9f46e1c567fb1a4fdf73956f8e912065b7c4c6af237e247d9c";
const NAMEWRAPPER = "cfxtest:acapc3y2j7atme3bawvaex18hs36tn40uu5h6j3mtu";

async function main() {
  const [signer] = await conflux.getSigners();

  console.log(`signer address is: `, signer.address);

  const CNSUtils = await conflux.getContractFactory("CNSUtils");

  console.log("deploy CNSUtils contract");

  const receipt = await CNSUtils.constructor(
    STORE_ADDR,
    CNSMARKETPLACE_ADDR,
    NAMEWRAPPER
  )
    .sendTransaction({
      from: signer.address,
    })
    .executed();

  console.log(
    `Contract deploy ${receipt.outcomeStatus === 0 ? "Success" : "Failed"}`
  );

  const contractAddress = receipt.contractCreated;
  console.log(`New deployed contract address: ${contractAddress}`);

  // grant call role to cns marketplace
  console.log("grant CNSUtils with call role");
  const store = await conflux.getContractAt("Store", STORE_ADDR);
  await store
    .grantRole(ROLE_CALL, contractAddress)
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
