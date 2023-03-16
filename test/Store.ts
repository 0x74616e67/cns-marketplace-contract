// @ts-nocheck
import { expect } from "chai";
import { conflux } from "hardhat";

describe("Store contract", function () {
  it("Store roll call should not empty", async function () {
    const [owner] = await conflux.getSigners();

    const Store = await conflux.getContractFactory("Store");

    const receipt = await Store.constructor()
      .sendTransaction({
        from: owner.address,
      })
      .executed();

    console.log(
      `Contract deploy ${receipt.outcomeStatus === 0 ? "Success" : "Failed"}`
    );

    const contractAddress = receipt.contractCreated;
    console.log(`New deployed contract address: ${contractAddress}`);

    // const rollcall = await hardhatStore.ROLE_CALL();
    // expect(await hardhatStore.ROLE_CALL()).not("");
    // expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });
});
