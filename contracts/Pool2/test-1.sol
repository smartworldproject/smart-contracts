// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IUniswapRouter.sol";
import "./ISmartWorld.sol";
import "./Secure.sol";

contract SmartPoolTest is Secure {
  using SafeMath for uint256;

  IUniswapRouter internal UniswapRouter;
  ISmartWorld internal SmartWorld;

  address public constant STT = 0x75Bea6460fff60FF789F88f7FE005295B8901455;
  address public constant STTS = 0xBFd0Ac6cD15712E0a697bDA40897CDc54b06D7Ef;
  address public constant ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
  address public constant LPTOKEN = 0x3403db5EDd2541Aaa3793De4C0FFb31463A3D1cF;

  uint256 public MAX_PERCENT = 10000;
  uint256 public MAX_SLIPPAGE = 50;

  uint8 private LEVEL_1_LIMIT = 3;
  uint256 private PERIOD_DAYS = 37;
  uint256 private MINIMUM_STTS = 7 * 10**8;
  uint256 private PERIOD_TIMES = 37 minutes;
  uint16[7] private LEVELS = [3, 9, 27, 81, 243, 729, 2187];
  uint40[3] private PERCENTAGE = [20615843616, 13743895725, 6871947862];

  constructor() {
    SmartWorld = ISmartWorld(STT);
    UniswapRouter = IUniswapRouter(ROUTER);
  }

  function maxStts() public view returns (uint256 stts) {
    for (uint256 i = SmartWorld.sttPrice(); i > 0; i--) {
      if ((2**i).mod(i) == 0) return i.mul(MINIMUM_STTS);
    }
  }

  function freezePrice() public view returns (uint256 stts, uint256 bnb) {
    stts = maxStts();
    bnb = SmartWorld.sttsToBnb(stts);
  }

  function freezePriceInfo(uint256 percent)
    external
    view
    returns (
      uint256 stts,
      uint256 bnb,
      uint256 minStts,
      uint256 minBnb,
      uint256 slippage
    )
  {
    (stts, bnb) = freezePrice();
    slippage = percent > 0 ? percent : MAX_SLIPPAGE;
    minStts = stts.mul(uint256(MAX_PERCENT).sub(slippage)).div(MAX_PERCENT);
    minBnb = bnb.mul(uint256(MAX_PERCENT).sub(slippage)).div(MAX_PERCENT);
  }

  function addLiquidity(
    uint256 sttsAmount,
    uint256 amountSTTSMin,
    uint256 amountBNBMin,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    )
  {
    require(
      IERC20(STTS).transferFrom(_msgSender(), address(this), sttsAmount),
      "Error::SmartPool, Transfer failed"
    );

    (amountToken, amountETH, liquidity) = UniswapRouter.addLiquidityETH{value: msg.value}(
      STTS,
      sttsAmount,
      amountSTTSMin,
      amountBNBMin,
      address(this),
      deadline
    );

    require(liquidity > 0, "Error::SmartPool, Deposit failed!");

    if (msg.value > amountETH) _safeTransferETH(_msgSender(), msg.value - amountETH);
  }

  receive() external payable {}
}
