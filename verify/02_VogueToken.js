const hre = require("hardhat");
const dotenv = require("dotenv");

dotenv.config();

const UniswapV2Router02 = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D';

const treasuryWallet = '0x6108027B79C746d99C5a08815661815E24d2EaE8';

const VOGUE_ADDR = process.env.VOGUE_ADDR;


async function verifyVOGUE() {
  console.log("Begin verify VOGUE");
  await hre.run("verify:verify", {
    address: VOGUE_ADDR,
    constructorArguments: [treasuryWallet, UniswapV2Router02],
  });
  console.log("Done verify VOGUE");
}

async function main() {
  
  await verifyVOGUE();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
