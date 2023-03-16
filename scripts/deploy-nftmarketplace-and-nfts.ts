import { ethers } from "hardhat";

async function main() {
  const accounts = await ethers.getSigners();
  const [mOwner, nOwner, buyer1] = accounts;

  // deploy NFTMarketplace
  const NFTMarketplace = await ethers.getContractFactory(
    "NFTMarketplace",
    mOwner
  );
  const nftmarketplace = await NFTMarketplace.deploy();

  await nftmarketplace.deployed();
  console.log(`nftmarketplace deployed success.`);

  // deploy NFT1
  const NFT1 = await ethers.getContractFactory("MyNFT1", nOwner);
  const nft1 = await NFT1.deploy();

  await nft1.deployed();
  console.log(`nft1 deployed success.`);

  // deploy NFT2
  const NFT2 = await ethers.getContractFactory("MyNFT2", nOwner);
  const nft2 = await NFT2.deploy();

  await nft2.deployed();
  console.log(`nft2 deployed success.`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
