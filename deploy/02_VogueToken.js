
const dotenv = require('dotenv');
dotenv.config();

const UniswapV2Router02 = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D';
const treasuryWallet = '0x6108027B79C746d99C5a08815661815E24d2EaE8';


  module.exports = async function ({ ethers, getNamedAccounts, deployments, getChainId }) {
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();
  
    await deploy('VogueToken', {
      from: deployer,
      log: true,
      args: [treasuryWallet, UniswapV2Router02],
      deterministicDeployment: false,
      allowUnlimitedContractSize: true,
    });
  };
  
  module.exports.tags = ['VogueToken', 'VogueToken'];
  