const hre = require("hardhat");
const dotenv = require("dotenv");

dotenv.config();

const MorkERC20_ADDR = process.env.MorkERC20_ADDR;


async function verifyMockERC20() {
  console.log("Begin verify MockERC20");
  await hre.run("verify:verify", {
    address: MorkERC20_ADDR,
    constructorArguments: ['pToken', 'pToken'],
  });
  console.log("Done verify MockERC20");
}

async function main() {
  
  await verifyMockERC20();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
