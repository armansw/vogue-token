const { expect } = require("chai");

describe("Staking contract", function () {
//   let totalSupply = "10000000000000000000000"; // 10000 * 1e18
  let Token;
  let hardhatToken;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    Token = await ethers.getContractFactory("MockERC20");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    hardhatToken = await Token.deploy("VOGUE", "VOGUE");
  });

  // You can nest describe calls to create subsections.
  describe("Deployment", function () {
    it("Should assign the total supply of tokens to the owner", async function () {
      const ownerBalance = await hardhatToken.balanceOf(owner.address);
      expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
    });

    //? init status
    
    //* uint256 public periodFinish = 0;
    //* uint256 public rewardRate = 0;
    //* uint256 public rewardsDuration = 7 days;

    //* constructor ()
    //***  rewardsToken = IERC20(_rewardsToken);
    //***  stakingToken = IERC20(_stakingToken);
    //***  rewardsDistribution = _rewardsDistribution;
    //***  periodFinish = 0 ; normal


    //? First staking (10e18) mVOGUE
    //* updateReward(msg.sender)
    //*   rewardPerTokenStored = rewardPerToken() = 0;
    //*   lastUpdateTime = lastTimeRewardApplicable() = 0;
    //*     rewards[account] = earned(account) = 0;
    //*     userRewardPerTokenPaid[account] = rewardPerTokenStored = 0;

    //* _totalSupply = _totalSupply.add(10e18);  10e18
    //* _balances[msg.sender] = _balances[msg.sender].add(amount); 10e18
    //* emit Staked(msg.sender, amount);
    


    //? 1st getReward
    //*   getReward() -> 0 
    //* getReward will work once notifyRewardAmount is called by RewardsDistribution contract


    //? assume trasfer reswardTokens balance 100e18 of address(this)

    //? 1st notifyRewardAmount(100e18)
      //* updateReward(address(0))
        //* rewardPerTokenStored = rewardPerToken(); = 0
        //* lastUpdateTime = lastTimeRewardApplicable(); = 0

      //* if (block.timestamp >= periodFinish::0 ) {
        //* rewardRate = reward.div(rewardsDuration);  100e18 / 7days
        //* uint balance = rewardsToken.balanceOf(address(this));
        
        //* require(rewardRate <= balance.div(rewardsDuration), "Provided reward too high"); 
        //! this requires staking contract balance must be charged before call notifyRewardAmount
      //* lastUpdateTime = block.timestamp;
      //* periodFinish = block.timestamp.add(rewardsDuration:: 7days);
      //* emit RewardAdded(reward);


    //? 2nd getReward  ( block.timestamp :: = lastUpdateTime + 1000 < periodFinish )
      //* updateReward(msg.sender)
        //* rewardPerTokenStored = rewardPerToken(); = 
            //* rewardPerTokenStored.add(
            //*     lastTimeRewardApplicable()::block.timestamp.sub(lastUpdateTime).mul(rewardRate::100e18 / 7days).mul(1e18).div(_totalSupply:: 10e18)
            //!      1000 * 100e18 / 7days * 1e18 / 10e18 = 100 * 100e18 / 7days => rewardPerTokenStored
            //* );
        //* lastUpdateTime = lastTimeRewardApplicable(); = block.timestamp
        //* if (account != address(0)) {
        //*     rewards[account] = earned(account); <= _balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
        //!     rewards[account]  = earned(account) = (10e18 * ( (2 * 100 * 100e18 / 7days) -  0) / 1e18) +  0 = 2000 * 100e18/ 7days
        //*     userRewardPerTokenPaid[account] = rewardPerTokenStored; => 100 * 100e18 / 7days 
        //* }

        //* uint256 reward = rewards[msg.sender]; => 2000 * 100e18/ 7days
        //* if (reward > 0) {
        //*   rewards[msg.sender] = 0;
        //*   rewardsToken.safeTransfer(msg.sender, reward);
        //*   emit RewardPaid(msg.sender, reward);
        //* }
        //! sender received rewards token in 2000 * 100e18/ 7days
      

  });

  describe("Transactions", function () {
    


   
  });
});
