// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISmartPool {
  event WithdrawInterest(address indexed user, uint256 daily, uint256 referrals);
  event Freeze(address indexed user, address indexed referrer, uint256 amount);
  event Unfreeze(address indexed user, uint256 sttsAmount, uint256 bnbAmount);
  event UpdateFreeze(address indexed user, uint256 amount);

  function maxStts() external view returns (uint256);

  function freezePrice() external view returns (uint256 stts, uint256 bnb);

  function updatePrice(address user) external view returns (uint256 stts, uint256 bnb);

  function userFreezeInfo(address user, uint256 percent)
    external
    view
    returns (
      uint256 stts,
      uint256 bnb,
      uint256 minStts,
      uint256 minBnb,
      uint256 slippage
    );

  function userUnfreezeInfo(address user, uint256 percent)
    external
    view
    returns (
      uint256 stts,
      uint256 bnb,
      uint256 minStts,
      uint256 minBnb,
      uint256 slippage
    );

  function priceInfo(uint256 stts, uint256 percent)
    external
    view
    returns (
      uint256 bnb,
      uint256 minStts,
      uint256 minBnb,
      uint256 slippage
    );

  function freeze(
    address referrer,
    uint256 amountSTTSMin,
    uint256 amountBNBMin,
    uint256 deadline
  ) external payable;

  function updateFreeze(
    uint256 amountSTTSMin,
    uint256 amountBNBMin,
    uint256 deadline
  ) external payable;

  function unfreeze(
    uint256 amountSTTSMin,
    uint256 amountBNBMin,
    uint256 deadline
  ) external;

  function calulateBnb(uint256 stts) external view returns (uint256 bnb);

  function withdrawInterest() external returns (bool);

  function calculateInterest(address user)
    external
    view
    returns (
      uint256 daily,
      uint256 referral,
      uint256 requestTime
    );

  function calculateDaily(address sender, uint256 time) external view returns (uint256 daily);

  function userRemainingDays(address user) external view returns (uint256);

  function userDepositNumber(address user) external view returns (uint256);

  function userDepositTimes(address user) external view returns (uint256[] memory);

  function userExpireTime(address user) external view returns (uint256);

  function userExpired(address user) external view returns (bool);
}
