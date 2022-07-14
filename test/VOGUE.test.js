const { expect } = require("chai");
const { ethers } = require("hardhat");
const { deployContract } = require("ethereum-waffle");
const weth9 =  require('canonical-weth/build/contracts/WETH9.json');

const ERC20 = require("@uniswap/v2-core/build/ERC20.json");
const IUniswapV2Pair = require("@uniswap/v2-core/build/IUniswapV2Pair.json");
const compiledUniswapFactory = require("@uniswap/v2-core/build/UniswapV2Factory.json");
const compiledUniswapRouter = require("@uniswap/v2-periphery/build/UniswapV2Router02.json");

const { BigNumber } = require("ethers");
const BN = require('bignumber.js');

const overrides = {
  gasLimit: 9999999,
};

describe("VOGUEToken Test", async function () {
  let owner, user1, user2, user3, treasuryWallet;
  let vogue, weth, factory, router, pair;
  let vogue_pool_amount;

  before(async function () {
    [owner, user1, user2, user3, treasuryWallet] = await ethers.getSigners();
    console.log("Owner:", owner.address);
    console.log("treasuryWallet:", treasuryWallet.address);

    // Weth

    weth = await new ethers.ContractFactory(weth9.abi, weth9.bytecode, owner).deploy();
    await weth.deployed();

    
    // --- uniswap factory

    factory = await new ethers.ContractFactory(
      compiledUniswapFactory.interface,
      compiledUniswapFactory.bytecode,
      owner
    ).deploy(await owner.getAddress());
    await factory.deployed();
    console.log("Uniswap Factory:", factory.address);

    // --- uniswap router
    
    const router = await new ethers.ContractFactory(
      compiledUniswapRouter.abi,
      compiledUniswapRouter.bytecode,
      owner
    ).deploy(factory.address, weth.address);
    await router.deployed();
    console.log("Uniswap Router:", router.address);
    console.log(
      "Router:",
      router.address,
      "Router Factory:",
      await router.factory()
    );


    // VOGUEToken
    const VOGUEToken = await ethers.getContractFactory("VogueToken");
    vogue = await VOGUEToken.deploy(treasuryWallet.address, router.address);
    await vogue.deployed();

    console.log("Vogue Token Deployed Address: ", vogue.address);

    // Uniswap Pair
    const pairAddress = await factory.getPair(vogue.address, weth.address);
    pair = new ethers.Contract(
      pairAddress,
      JSON.stringify(IUniswapV2Pair.abi),
      owner
    ).connect(owner);
    console.log("Pair:", pair.address, "Pair Factory:", await pair.factory());

    // Test ERC20 Token
    const token = await deployContract(owner, ERC20, [
      ethers.utils.parseEther("10000"),
    ]);

    await factory.createPair(token.address, weth.address);

    const tokenPairAddress = await factory.getPair(token.address, weth.address);
    const tokenPair = new ethers.Contract(
      tokenPairAddress,
      JSON.stringify(IUniswapV2Pair.abi),
      owner
    ).connect(owner);
    console.log(
      "Token Pair:",
      tokenPair.address,
      "Token Pair Factory:",
      await tokenPair.factory()
    );

    vogue_pool_amount = ethers.utils.parseEther("1000");
    const eth_amount = 100;

    console.log('addLiquidityETH for vogue token amount: ', vogue_pool_amount.toString())
    await vogue.approve(router.address, ethers.constants.MaxUint256);
    await router.addLiquidityETH(
      vogue.address,
      vogue_pool_amount,
      0,
      0,
      owner.address,
      ethers.constants.MaxUint256,
      {
        ...overrides,
        value: eth_amount,
      }
    );

    console.log('Balance of owner: ', new BN((await vogue.balanceOf(owner.address)).toString()).dividedBy(10**18).toString() );


    // Default ERC20 token is working well
    console.log('addLiquidityETH for Pair Token  amount: ', (ethers.utils.parseEther("1000")).toString())
    await token.approve(router.address, ethers.constants.MaxUint256);
    await router.addLiquidityETH(
      token.address,
      ethers.utils.parseEther("1000"),
      0,
      0,
      owner.address,
      ethers.constants.MaxUint256,
      {
        ...overrides,
        value: 100,
      }
    );



    console.log('Balance of owner: ', new BN((await vogue.balanceOf(owner.address)).toString()).dividedBy(10**18).toString() );

  });

  describe("Initial checks", async () => {
    it("Check token details", async () => {
      const _DECIMALS = 18;
      const _tTotal = new BN('1').multipliedBy(10**9).multipliedBy(10**_DECIMALS);
      const _rTotal = new BN(ethers.constants.MaxUint256.toString()).minus( new BN( ethers.constants.MaxUint256.toString()).mod( _tTotal) ) ;
      console.log('_rTotal : ', _rTotal.toString());

      const balanceOfrTotal = await vogue.tokenFromReflection('115792089237316195423570985008687907853269984665640000000000000000000000000000');
      // console.log('balanceOfrTotal : tokenFromReflection :: ', new BN(balanceOfrTotal.toString()).dividedBy(10**18).toString() );
      console.log('balanceOfrTotal : tokenFromReflection :: ', new BN(balanceOfrTotal.toString()).dividedBy(10**18).toString());

      const curOwnerBalBN = new BN((await vogue.balanceOf(owner.address)).toString());
      const addedPoolVogueAmountBN = new BN(balanceOfrTotal.toString()).minus(curOwnerBalBN)
      console.log('Diff: addedLiquidity VogueToken: ',   addedPoolVogueAmountBN.dividedBy(10**18).toString() );

      console.log('vogue_pool_amount: ', vogue_pool_amount.toString(), addedPoolVogueAmountBN.toString())

      expect(addedPoolVogueAmountBN.minus(new BN(vogue_pool_amount.toString())).toNumber()).to.be.eq(0); // 1 Quadrillion - 10k (LP)
      console.log('Confirmed addedPoolVogueAmountBN 1000 VOGUE')


      const totalSupplyBN = new BN((await vogue.totalSupply()).toString());
      console.log('VOGUE total Supply : ', totalSupplyBN.toString() )
      
      expect( totalSupplyBN.isEqualTo(10**27) ).to.be.eq(true);
      console.log('Confirmed VOGUE total supply is 1e9 VOGUE')

      expect(await vogue.owner()).to.be.eq(owner.address);
      expect(await vogue.name()).to.be.eq("VOGUE Token");
      expect(await vogue.symbol()).to.be.eq("VOGUE");
    });

    it("Check liquidity", async () => {

      const factory_pair = await factory.getPair(vogue.address, weth.address);
      console.log("Pair:", factory_pair.address);
    });
  });

  describe('Check swap and fees', async () => {
      it('Transfer tokens to another user (no fee)', async () => {
          const ownerBalanceBN = new BN((await vogue.balanceOf(owner.address)).toString())

          await vogue.connect(owner).transfer(user1.address, ethers.utils.parseEther('500')) // -500 VOGUE
          expect(await vogue.balanceOf(user1.address)).to.be.eq(ethers.utils.parseEther('500'))
          console.log('Confirmed : User1 balance of VOGUE : 500' )
          const afterTransferOwnerBalanceBN = new BN((await vogue.balanceOf(owner.address)).toString())
          console.log(ownerBalanceBN, afterTransferOwnerBalanceBN, ownerBalanceBN.minus(afterTransferOwnerBalanceBN).toString())
          expect(ownerBalanceBN.minus(afterTransferOwnerBalanceBN).isEqualTo(new BN(ethers.utils.parseEther('500').toString()))).to.be.eq(true);
          console.log('Confirmed owner balance reduced by 500 VOGUE')
      })

      // it('Non-whitelisted sell', async () => {
      //     await approveTokens([vogue.connect(user1), busd.connect(user1)], pancakeRouter.address)
      //     await swapExactTokensForETH(pancakeRouter.connect(user1), {
      //         amountToken: parseEther('100'),
      //         path: [vogue.address, weth.address],
      //         to: user1.address
      //     })
      // })
  })
});
