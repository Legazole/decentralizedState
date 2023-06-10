import { ethers } from "hardhat";
async function main() {
  const provider = new ethers.providers.JsonRpcProvider(
    process.env.SEPOLIA_RPC
  );

  const hero = new ethers.Wallet(process.env.HERO_PRIVATE_KEY!, provider);

  const propertyAddress: string | undefined = process.env.PROPERTY_ADDRESS!;
  const usdcContractAddress: string | undefined = process.env.USDC_ADDRESS!;

  const usdcAbi = [
    "function approve(address spender, uint256 value) returns (bool)",
    "function allowance(address owner, address spender) view returns (uint256)",
    "function balanceOf(address) view returns (uint256)",
    "function decimals() view returns (uint8)",
  ];

  const usdcContract = new ethers.Contract(usdcContractAddress, usdcAbi, hero);
  const propertyContract = await ethers.getContractAt(
    "Property",
    propertyAddress,
    hero
  );

  const usdcDecimals = await usdcContract.decimals();
  console.log(`usdc amount of decimals: ${usdcDecimals}`);
  const share: number = 1;

  const sharePrice = await propertyContract.getPriceForShare(share);

  console.log(`the price of share : ${share} is ${sharePrice}`);

  const propertyContractHeroAllowance = await usdcContract.allowance(
    hero.getAddress(),
    propertyAddress
  );
  console.log(
    `the property contract can currently spend ${propertyContractHeroAllowance} usdc from hero account`
  );

  await approvePropertyContract(
    sharePrice.toNumber(),
    usdcContract,
    propertyAddress
  );

  const heroBalance = await usdcContract.balanceOf(hero.getAddress());
  const heroBalanceAdjustedForDecimals = heroBalance / 10 ** usdcDecimals;
  console.log(
    `the hero current has a usdc balance of ${heroBalanceAdjustedForDecimals}`
  );
  const propertyContractAllowance = await usdcContract.allowance(
    hero.getAddress(),
    propertyAddress
  );
  console.log(
    `the property contract can now spend ${propertyContractAllowance} from the hero account`
  );
}

async function approvePropertyContract(
  sharePrice: number,
  usdcContract: any,
  propertyAddress: string
) {
  const c = await usdcContract.balanceOf(propertyAddress);
  console.log(c);
}

async function buyShare(share: number, property: any) {
  const updateURIEvent = property.filters.UpdateURI();

  property.on(updateURIEvent, (receiver: string, share: number) => {});
}

async function sendNewEncryption() {}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
