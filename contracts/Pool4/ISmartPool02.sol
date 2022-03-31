// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISmartPool {
  event WithdrawInterest(address indexed user, uint256 daily, uint256 referrals);
  event Freeze(address indexed user, address indexed referrer, uint256 amount);
  event FreezeLP(address indexed user, address indexed referrer, uint256 amount);
  event Unfreeze(address indexed user, uint256 sttsAmount, uint256 bnbAmount);
  event UnfreezeLP(address indexed user, uint256 amount);
  event UpdateFreeze(address indexed user, uint256 amount);
  event UpdateFreezeLP(address indexed user, uint256 amount);
  event ReferralReward(address indexed user, uint256 amount);

  function totalLiquidity() external view returns (uint256);

  function sttsToBnbPrice() external view returns (uint256);

  function freezeInfo(uint256 stts, uint256 percent)
    external
    view
    returns (
      uint256 reward,
      uint256 bnb,
      uint256 minStts,
      uint256 minBnb,
      uint256 slippage
    );

  function unfreezeInfo(address user, uint256 percent)
    external
    view
    returns (
      uint256 stts,
      uint256 bnb,
      uint256 minStts,
      uint256 minBnb,
      uint256 slippage
    );

  function freezeLP(
    address referrer,
    uint256 refPercent,
    uint256 lpAmount
  ) external;

  function freeze(
    address referrer,
    uint256 refPercent,
    uint256 sttsAmount,
    uint256 amountSTTSMin,
    uint256 amountBNBMin,
    uint256 deadline
  ) external payable;

  function updateFreeze(
    uint256 sttsAmount,
    uint256 amountSTTSMin,
    uint256 amountBNBMin,
    uint256 deadline
  ) external payable;

  function updateFreezeLP(uint256 lpAmount) external;

  function unfreeze(
    uint256 amountSTTSMin,
    uint256 amountBNBMin,
    uint256 deadline
  ) external;

  function unfreezeLP() external;

  function calculateLiquidityValue(uint256 liquidity)
    external
    view
    returns (
      uint256 stts,
      uint256 bnb,
      uint256 total
    );

  function calculateReward(uint256 liquidity) external view returns (uint256);

  function calculateRef(uint256 value) external view returns (uint256);

  function calculatePercent(uint256 value, uint256 percent)
    external
    view
    returns (uint256 userValue, uint256 refValue);

  function calculateBnb(uint256 stts) external view returns (uint256);

  function withdrawInterest() external returns (bool);

  function calculateInterest(address user)
    external
    view
    returns (
      uint256 daily,
      uint256 referral,
      uint256 referrer,
      uint256 requestTime
    );

  function calculateDaily(address sender, uint256 time) external view returns (uint256 daily);

  function userDepositNumber(address user) external view returns (uint256);

  function userDepositDetails(address user, uint256 index)
    external
    view
    returns (uint256 startTime, uint256 reward);
}
