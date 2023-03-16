import { ethers } from "hardhat";

const PRICE = ethers.utils.parseEther("0.1");

async function main() {
  const accounts = await ethers.getSigners();
  const [deployer, nftContractOwner, buyer1] = accounts;

  const IDENTITIES = {
    [deployer.address]: "DEPLOYER", // 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
    [nftContractOwner.address]: "OWNER", // 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
    [buyer1.address]: "BUYER_1", // 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC
  };

  const marketplaceContract = await ethers.getContractAt(
    "NFTMarketplace",
    "0x5fbdb2315678afecb367f032d93f642f64180aa3"
  );

  const nft1Contract = await ethers.getContractAt(
    "MyNFT1",
    "0x8464135c8f25da09e49bc8782676a84730c318bc"
  );

  const nft2Contract = await ethers.getContractAt(
    "MyNFT2",
    "0x71c95911e9a5d330f4d621842ec243ee1343292e"
  );

  const tx = await nft1Contract
    .connect(nftContractOwner)
    .safeMint(nftContractOwner.address);
  await tx.wait();

  const tx2 = await nft1Contract
    .connect(nftContractOwner)
    .safeMint(nftContractOwner.address);
  await tx2.wait();

  // console.log("tx is: ", tx);
  console.log("owner of tokenid 0: ", await nft1Contract.ownerOf(0));
  console.log("owner of tokenid 1: ", await nft1Contract.ownerOf(1));

  await marketplaceContract
    .connect(nftContractOwner)
    .listItem(nft1Contract.address, 0, ethers.utils.parseEther("0.1"), {
      gasLimit: 1000000,
      gasPrice: ethers.utils.parseUnits("1", "gwei"),
      type: 0,
    });
  await marketplaceContract
    .connect(deployer)
    .listItem(nft1Contract.address, 0, ethers.utils.parseEther("0.1"));

  await marketplaceContract.connect(buyer1).buyItem(nft1Contract.address, 0, {
    gasLimit: 1000000,
    gasPrice: ethers.utils.parseUnits("1", "gwei"),
    type: 0,
    value: ethers.utils.parseEther("0.1"),
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
