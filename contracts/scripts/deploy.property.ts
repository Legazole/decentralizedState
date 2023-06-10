import { ethers } from "hardhat";

async function main() {
  const multiSigAddress = process.env.ADDRESS;
  const usdcAddress = process.env.USDC_ADDRESS;

  const Property = await ethers.getContractFactory("Property");
  const property = await Property.deploy(multiSigAddress, usdcAddress);

  await property.deployed();

  console.log(`property nft deployed at ${property.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
