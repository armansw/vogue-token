require("@nomiclabs/hardhat-waffle");
require("hardhat-deploy");
require("hardhat-deploy-ethers");
require('dotenv').config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const accounts = {
  mnemonic:
    process.env.MNEMONIC ||
    "test test test test test test test test test test test junk",
  // accountsBalance: "990000000000000000000",
};

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  
  defaultNetwork: "rinkeby",

  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
    dev: {
      default: 1,
    },
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    hardhat: {
      // hardfork: "london",
      allowUnlimitedContractSize: true,
      settings: {
        optimizer: {
          enabled: true,
          runs: 9999,
        },
      },
      initialBaseFeePerGas: 0,
      // evmVersion: "byzantium",
      // forking: {
      //   url: "https://eth-rinkeby.alchemyapi.io/v2/8SAQa7xMc0VXTR_hyfPvAt2pe3QrXybB",
      //   // url: "https://rinkeby.infura.io/v3/543a595517b74e008ed1cddf79c46cf8",
      //   enabled: true,
      //   blockNumber: 10375927,
      // },
      // gasPrice: "auto",
      accounts,
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${process.env.INFURA_KEY}`,
      accounts,
    
      chainId: 4,
      allowUnlimitedContractSize: true,
      live: false,
      saveDeployments: true,
      gasPrice: 5000000000,
      gasMultiplier: 2,
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_KEY}`,
      accounts,
      chainId: 1,
      live: false,
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
      saveDeployments: true
    },
  },
  paths: {
    deploy: "deploy",
    deployments: "deployments",
    sources: "contracts",
    tests: "test",
    artifacts: "./artifacts",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
    // {
    //   polygon: process.env.POLYGONSCAN_API_KEY,
    //   polygonMumbai: process.env.POLYGONSCAN_API_KEY,
    //   rinkeby: "YOUR_ETHERSCAN_API_KEY",
    //   mainnet: "YOUR_ETHERSCAN_API_KEY",
    // }
  },

  abiExporter: [
    {
      path: './abi/pretty',
      pretty: true,
    },
    {
      path: './abi/ugly',
      pretty: false,
    },
  ]

};
