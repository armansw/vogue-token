const { expect } = require("chai")
const { ethers } = require("hardhat")
const { deployContract } = require('ethereum-waffle')
const UniswapV2Factory = require('../build/UniswapV2Factory.json')
const UniswapV2Router02 = require('../build/UniswapV2Router02.json')
const IUniswapV2Pair = require('../build/IUniswapV2Pair.json')
// const WETH18 = require('../build/WETH18.json')
// const ERC20 = require('../build/ERC20.json')

const overrides = {
  gasLimit: 9999999
}

describe("VOGUEToken", async function() {  
    let owner, user1, user2, user3, user4;
    let huh, weth, factory, router, pair;

    before(async function () {
      [owner, user1, user2, user3, user4] = await ethers.getSigners()
      console.log('Owner:', owner.address)

      // Weth
      weth = await deployContract(owner, WETH18)
      console.log("Weth:", weth.address)

      // Uniswap Factory
      factory = await deployContract(owner, UniswapV2Factory, [owner.address])
      console.log('Factory:', factory.address)

      // Uniswap Router
      router = await deployContract(owner, UniswapV2Router02, [factory.address, weth.address])
      console.log('Router:', router.address, 'Router Factory:', await router.factory())

      // Huh Token
      const VOGUEToken = await ethers.getContractFactory('VOGUEToken')
      huh = await VOGUEToken.deploy(router.address)
      await huh.deployed()
      console.log('Token: ', huh.address)
      
      // Uniswap Pair
      const pairAddress = await factory.getPair(huh.address, weth.address)
      pair = new ethers.Contract(pairAddress, JSON.stringify(IUniswapV2Pair.abi), owner).connect(owner)
      console.log('Pair:', pair.address, 'Pair Factory:', await pair.factory())

      // Test ERC20 Token
      const token = await deployContract(owner, ERC20, [ethers.utils.parseEther("10000")])
      await factory.createPair(token.address, weth.address)
      const tokenPairAddress = await factory.getPair(token.address, weth.address)
      const tokenPair = new ethers.Contract(tokenPairAddress, JSON.stringify(IUniswapV2Pair.abi), owner).connect(owner)
      console.log('Token Pair:', tokenPair.address, 'Token Pair Factory:', await tokenPair.factory())

      const huh_amount = ethers.utils.parseEther("1000")
      const eth_amount = 100 

      // Huh token has issue in transferFrom function, we need to fix it before addLiquidityETH
      await huh.approve(router.address, ethers.constants.MaxUint256)
      await router.addLiquidityETH(huh.address, huh_amount, 0, 0, owner.address,  ethers.constants.MaxUint256, {
        ...overrides,
        value : eth_amount 
      })

      // Default ERC20 token is working well
      await token.approve(router.address, ethers.constants.MaxUint256)
      await router.addLiquidityETH(token.address, ethers.utils.parseEther("1000"), 0, 0, owner.address, ethers.constants.MaxUint256, {
        ...overrides,
        value : 100
      })
    })

    describe('Initial checks', async () => {
        it('Check token details', async () => {
            // expect(await huh.balanceOf(owner.address)).to.be.eq(ethers.utils.parseEther('1000000')) // 1 Quadrillion - 10k (LP)
            // expect(await huh.totalSupply()).to.be.eq(ethers.utils.parseEther('1000000'))
            // expect(await huh.owner()).to.be.eq(owner.address)
            // expect(await huh.name()).to.be.eq('VOGUEToken')
            // expect(await huh.symbol()).to.be.eq('HUH')
        })

        // it('Check liquidity', async () => {
        //     expect(await huh.balanceOf(owner.address)).to.be.eq(ethers.utils.parseEther('1000000'))

        //     const factory_pair = await factory.getPair(huh.address, weth.address)
        //     console.log('Pair:', factory_pair.address)
        // })
    })

    // describe('Check swap and fees', async () => {
    //     it('Transfer tokens to another user (no fee)', async () => {
    //         // await huh.connect(owner).transfer(user1.address, parseEther('500')) // -500 HUH
    //         // expect(await huh.balanceOf(user1.address)).to.be.eq(parseEther('500'))
    //         // expect(await huh.balanceOf(owner.address)).to.be.eq(parseEther('999999999979500'))
    //     })

    //     it('Non-whitelisted sell', async () => {
    //         // await approveTokens([huh.connect(user1), busd.connect(user1)], pancakeRouter.address)
    //         // await swapExactTokensForETH(pancakeRouter.connect(user1), {
    //         //     amountToken: parseEther('100'),
    //         //     path: [huh.address, weth.address],
    //         //     to: user1.address
    //         // })
    //     })
    // })
})

