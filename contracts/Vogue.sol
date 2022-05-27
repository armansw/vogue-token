// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IUniswap.sol";

import "hardhat/console.sol";

// abstract contract Context {
//     function _msgSender() internal view virtual returns (address payable) {
//         return msg.sender;
//     }

//     function _msgData() internal view virtual returns (bytes memory) {
//         this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
//         return msg.data;
//     }
// }

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Vogue is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string constant _NAME = "Vogue";
    string constant _SYMBOL = "VOGUE";
    uint8 constant _DECIMALS = 18;

    uint256 private constant _MAX = ~uint256(0);
    uint256 private _tTotal = 1 * 10**15 * (10**_DECIMALS); // 1 Quadrilion HUH
    uint256 private _rTotal = (_MAX - (_MAX % _tTotal));
    uint256 private _tFeeTotal;

    uint256 public liquidityFeeOnBuy = 1;
    uint256 public ETHreflectionFeeOnBuy = 5;
    uint256 public marketingFeeOnBuy = 1;
    uint256 public HuHdistributionFeeOnBuy = 8;

    uint256 public liquidityFeeOnBuyWhiteListed_A = 1;
    uint256 public ETHrewardFor1stPerson_A = 10;
    uint256 public marketingFeeOnBuyWhiteListed_A = 1;
    uint256 public HuHdistributionFeeOnBuyWhiteListed_A = 3;

    uint256 public liquidityFeeOnBuyWhiteListed_B = 1;
    uint256 public ETHrewardFor1stPerson_B = 10;
    uint256 public ETHrewardFor2ndPerson_B = 2;
    uint256 public marketingFeeOnBuyWhiteListed_B = 1;
    uint256 public HuHdistributionFeeOnBuyWhiteListed_B = 1;

    uint256 public liquidityFeeOnSell = 1;
    uint256 public ETHreflectionFeeOnSell = 5;
    uint256 public marketingFeeOnSell = 1;
    uint256 public HuHdistributionFeeOnSell = 8;

    uint256 public liquidityFeeOnSellWhiteListed = 1;
    uint256 public ETHreflectionFeeOnSellWhiteListed = 5;
    uint256 public marketingFeeOnSellWhiteListed = 1;
    uint256 public HuHdistributionFeeOnSellWhiteListed = 3;

    uint256 public launchedAt;
    uint256 public distributorGas = 500000;
    uint256 public minTokenAmountForGetReward = 10000 * (10**_DECIMALS);

    address public refCodeRegistrator; // Address who allowed to register code for users (will be used later)
    address public marketingFeeReceiver;
    address private constant _DEAD_ADDRESS =
        0x000000000000000000000000000000000000dEaD;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromDividend;
    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    mapping(address => bytes) public referCodeForUser;
    mapping(bytes => address) public referUserForCode;
    mapping(address => address) public referParent;
    mapping(address => bool) public isWhitelisted;
    mapping(address => bool) public isFirstBuy;

    IUniswapV2Router02 public pcsV2Router;
    address public pcsV2Pair;

    

    address public reward1stPerson;
    address public reward2ndPerson;
    mapping(address => uint256) public rewardAmount;

    bool public swapEnabled = true;
    uint256 public swapThreshold = 200000 * (10**_DECIMALS); // Swap every 200k tokens
    uint256 private _liquidityAccumulated;

    bool private _inSwap;
    modifier swapping() {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    event UserWhitelisted(address account, address referee);
    event CodeRegisterred(address account, bytes code);
    event SwapAndLiquify(uint256 ethReceived, uint256 tokensIntoLiqudity);

    //  -----------------------------
    //  CONSTRUCTOR
    //  -----------------------------

    constructor(address swapaddress) ERC20(_NAME, _SYMBOL) {
        IUniswapV2Router02 _pancakeswapV2Router = IUniswapV2Router02(
            swapaddress
        );

        pcsV2Pair = IUniswapV2Factory(_pancakeswapV2Router.factory())
            .createPair(address(this), _pancakeswapV2Router.WETH());
        pcsV2Router = _pancakeswapV2Router;

        _allowances[address(this)][address(pcsV2Router)] = _MAX;
        distributor = IDividendDistributor(new DividendDistributor());

        _rOwned[msg.sender] = _rTotal;
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;

        _isExcludedFromDividend[address(this)] = true;
        _isExcludedFromDividend[pcsV2Pair] = true;
        _isExcludedFromDividend[address(0)] = true;

        marketingFeeReceiver = msg.sender;

        emit Transfer(address(0), msg.sender, _tTotal);
    }

    receive() external payable {}

    fallback() external payable {}

    //  -----------------------------
    //  SETTERS (PROTECTED)
    //  -----------------------------

    function excludeFromReward(address account) public onlyOwner {
        _excludeFromReward(account);
    }

    function includeInReward(address account) external onlyOwner {
        _includeInReward(account);
    }

    function setIsExcludedFromFee(address account, bool flag)
        external
        onlyOwner
    {
        _setIsExcludedFromFee(account, flag);
    }

    function setIsExcludedFromDividend(address account, bool flag)
        external
        onlyOwner
    {
        _setIsExcludedFromDividend(account, flag);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        distributorGas = gas;
    }

    function changeMinAmountForReward(uint256 amount) external onlyOwner {
        minTokenAmountForGetReward = amount * (10**_DECIMALS);
    }

    function changeFeesForNormalBuy(
        uint256 _liquidityFeeOnBuy,
        uint256 _ETHreflectionFeeOnBuy,
        uint256 _marketingFeeOnBuy,
        uint256 _HuHdistributionFeeOnBuy
    ) external onlyOwner {
        liquidityFeeOnBuy = _liquidityFeeOnBuy;
        ETHreflectionFeeOnBuy = _ETHreflectionFeeOnBuy;
        marketingFeeOnBuy = _marketingFeeOnBuy;
        HuHdistributionFeeOnBuy = _HuHdistributionFeeOnBuy;
    }

    function changeFeesForWhiteListedBuy_1_RefererOnly(
        uint256 _liquidityFeeOnBuy,
        uint256 _ETHFeeOnBuy,
        uint256 _marketingFeeOnBuy,
        uint256 _HuHdistributionFeeOnBuy
    ) external onlyOwner {
        liquidityFeeOnBuyWhiteListed_A = _liquidityFeeOnBuy;
        ETHrewardFor1stPerson_A = _ETHFeeOnBuy;
        marketingFeeOnBuyWhiteListed_A = _marketingFeeOnBuy;
        HuHdistributionFeeOnBuyWhiteListed_A = _HuHdistributionFeeOnBuy;
    }

    function changeFeesForWhiteListedBuy_2_Referers(
        uint256 _liquidityFeeOnBuy,
        uint256 _ETH1stPersonFeeOnBuy,
        uint256 _ETH2ndPersonFeeOnBuy,
        uint256 _marketingFeeOnBuy,
        uint256 _HuHdistributionFeeOnBuy
    ) external onlyOwner {
        liquidityFeeOnBuyWhiteListed_B = _liquidityFeeOnBuy;
        ETHrewardFor1stPerson_B = _ETH1stPersonFeeOnBuy;
        ETHrewardFor2ndPerson_B = _ETH2ndPersonFeeOnBuy;
        marketingFeeOnBuyWhiteListed_B = _marketingFeeOnBuy;
        HuHdistributionFeeOnBuyWhiteListed_B = _HuHdistributionFeeOnBuy;
    }

    function changeFeesForNormalSell(
        uint256 _liquidityFeeOnSell,
        uint256 _ETHreflectionFeeOnSell,
        uint256 _marketingFeeOnSell,
        uint256 _HuHdistributionFeeOnSell
    ) external onlyOwner {
        liquidityFeeOnSell = _liquidityFeeOnSell;
        ETHreflectionFeeOnSell = _ETHreflectionFeeOnSell;
        marketingFeeOnSell = _marketingFeeOnSell;
        HuHdistributionFeeOnSell = _HuHdistributionFeeOnSell;
    }

    function changeFeesForWhitelistedSell(
        uint256 _liquidityFeeOnSellWhiteListed,
        uint256 _ETHreflectionFeeOnSellWhiteListed,
        uint256 _marketingFeeOnSellWhiteListed,
        uint256 _HuHdistributionFeeOnSellWhiteListed
    ) external onlyOwner {
        liquidityFeeOnSellWhiteListed = _liquidityFeeOnSellWhiteListed;
        ETHreflectionFeeOnSellWhiteListed = _ETHreflectionFeeOnSellWhiteListed;
        marketingFeeOnSellWhiteListed = _marketingFeeOnSellWhiteListed;
        HuHdistributionFeeOnSellWhiteListed = _HuHdistributionFeeOnSellWhiteListed;
    }

    function changeMarketingWallet(address marketingFeeReceiver_)
        external
        onlyOwner
    {
        require(
            marketingFeeReceiver_ != address(0),
            "Zero address not allowed!"
        );
        marketingFeeReceiver = marketingFeeReceiver_;
    }

    function setRefCodeRegistrator(address refCodeRegistrator_)
        external
        onlyOwner
    {
        refCodeRegistrator = refCodeRegistrator_;
    }

    function changeSwapThreshold(uint256 swapThreshold_) external onlyOwner {
        swapThreshold = swapThreshold_ * (10**_DECIMALS);
    }

    //**** MUST FIX  **/

    

    // function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
    //     public
    //     view
    //     returns (uint256)
    // {
    //     require(tAmount <= _tTotal, "Amount must be less than supply");
    //     if (!deductTransferFee) {
    //         (uint256 rAmount, , , , , ) = _getValues(tAmount);
    //         return rAmount;
    //     } else {
    //         (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
    //         return rTransferAmount;
    //     }
    // }

    // function tokenFromReflection(uint256 rAmount)
    //     public
    //     view
    //     returns (uint256)
    // {
    //     require(
    //         rAmount <= _rTotal,
    //         "Amount must be less than total reflections"
    //     );
    //     uint256 currentRate = _getRate();
    //     return rAmount.div(currentRate);
    // }

    // function excludeFromReward(address account) public onlyOwner {
    //     // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
    //     require(!_isExcluded[account], "Account is already excluded");
    //     if (_rOwned[account] > 0) {
    //         _tOwned[account] = tokenFromReflection(_rOwned[account]);
    //     }
    //     _isExcluded[account] = true;
    //     _excluded.push(account);
    // }

    // function includeInReward(address account) external onlyOwner {
    //     require(_isExcluded[account], "Account is already excluded");
    //     for (uint256 i = 0; i < _excluded.length; i++) {
    //         if (_excluded[i] == account) {
    //             _excluded[i] = _excluded[_excluded.length - 1];
    //             _tOwned[account] = 0;
    //             _isExcluded[account] = false;
    //             _excluded.pop();
    //             break;
    //         }
    //     }
    // }

    // function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
    //     // split the contract balance into halves
    //     uint256 half = contractTokenBalance.div(2);
    //     uint256 otherHalf = contractTokenBalance.sub(half);

    //     // capture the contract's current ETH balance.
    //     // this is so that we can capture exactly the amount of ETH that the
    //     // swap creates, and not make the liquidity event include any ETH that
    //     // has been manually sent to the contract
    //     uint256 initialBalance = address(this).balance;

    //     // swap tokens for ETH
    //     swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

    //     // how much ETH did we just swap into?
    //     uint256 newBalance = address(this).balance.sub(initialBalance);

    //     // add liquidity to uniswap
    //     addLiquidity(otherHalf, newBalance);

    //     emit SwapAndLiquify(half, newBalance, otherHalf);
    // }

    // function swapTokensForEth(uint256 tokenAmount) private {
    //     // generate the uniswap pair path of token -> weth
    //     address[] memory path = new address[](2);
    //     path[0] = address(this);
    //     path[1] = uniswapV2Router.WETH();

    //     _approve(address(this), address(uniswapV2Router), tokenAmount);

    //     // make the swap
    //     uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
    //         tokenAmount,
    //         0, // accept any amount of ETH
    //         path,
    //         address(this),
    //         block.timestamp
    //     );
    // }

    // function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
    //     // approve token transfer to cover all possible scenarios
    //     _approve(address(this), address(uniswapV2Router), tokenAmount);

    //     // add the liquidity
    //     uniswapV2Router.addLiquidityETH{value: ethAmount}(
    //         address(this),
    //         tokenAmount,
    //         0, // slippage is unavoidable
    //         0, // slippage is unavoidable
    //         owner(),
    //         block.timestamp
    //     );
    // }

    // //this method is responsible for taking all fee, if takeFee is true
    // function _tokenTransfer(
    //     address sender,
    //     address recipient,
    //     uint256 amount,
    //     bool takeFee
    // ) private {
    //     if (!takeFee) removeAllFee();

    //     if (_isExcluded[sender] && !_isExcluded[recipient]) {
    //         _transferFromExcluded(sender, recipient, amount);
    //     } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
    //         _transferToExcluded(sender, recipient, amount);
    //     } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
    //         _transferStandard(sender, recipient, amount);
    //     } else if (_isExcluded[sender] && _isExcluded[recipient]) {
    //         _transferBothExcluded(sender, recipient, amount);
    //     } else {
    //         _transferStandard(sender, recipient, amount);
    //     }

    //     if (!takeFee) restoreAllFee();
    // }

    // function _transferStandard(
    //     address sender,
    //     address recipient,
    //     uint256 tAmount
    // ) private {
    //     (
    //         uint256 rAmount,
    //         uint256 rTransferAmount,
    //         uint256 rFee,
    //         uint256 tTransferAmount,
    //         uint256 tFee,
    //         uint256 tLiquidity
    //     ) = _getValues(tAmount);
    //     _rOwned[sender] = _rOwned[sender].sub(rAmount);
    //     _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
    //     _takeLiquidity(tLiquidity);
    //     _reflectFee(rFee, tFee);
    //     emit Transfer(sender, recipient, tTransferAmount);
    // }

    // function _transferToExcluded(
    //     address sender,
    //     address recipient,
    //     uint256 tAmount
    // ) private {
    //     (
    //         uint256 rAmount,
    //         uint256 rTransferAmount,
    //         uint256 rFee,
    //         uint256 tTransferAmount,
    //         uint256 tFee,
    //         uint256 tLiquidity
    //     ) = _getValues(tAmount);
    //     _rOwned[sender] = _rOwned[sender].sub(rAmount);
    //     _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
    //     _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
    //     _takeLiquidity(tLiquidity);
    //     _reflectFee(rFee, tFee);
    //     emit Transfer(sender, recipient, tTransferAmount);
    // }

    // function _transferFromExcluded(
    //     address sender,
    //     address recipient,
    //     uint256 tAmount
    // ) private {
    //     (
    //         uint256 rAmount,
    //         uint256 rTransferAmount,
    //         uint256 rFee,
    //         uint256 tTransferAmount,
    //         uint256 tFee,
    //         uint256 tLiquidity
    //     ) = _getValues(tAmount);
    //     _tOwned[sender] = _tOwned[sender].sub(tAmount);
    //     _rOwned[sender] = _rOwned[sender].sub(rAmount);
    //     _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
    //     _takeLiquidity(tLiquidity);
    //     _reflectFee(rFee, tFee);
    //     emit Transfer(sender, recipient, tTransferAmount);
    // }
}
