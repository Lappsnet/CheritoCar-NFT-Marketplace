import { ethers } from "hardhat";

async function main() {
  // Deploy NFT Contract
  const CheritoCarNFT = await ethers.getContractFactory("CheritoCarNFT");
  const nft = await CheritoCarNFT.deploy();
  await nft.waitForDeployment();
  console.log("CheritoCarNFT deployed to:", await nft.getAddress());

  // Deploy Marketplace
  const Marketplace = await ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy();
  await marketplace.waitForDeployment();
  console.log("Marketplace deployed to:", await marketplace.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});