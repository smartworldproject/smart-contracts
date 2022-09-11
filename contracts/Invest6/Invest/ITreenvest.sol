// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IUserData.sol";

interface ITreenvest {
  event WithdrawInterest(
    address indexed user,
    uint256 hourly,
    uint256 referrals,
    uint256 gift
  );

  event WithdrawInvest(address indexed user, uint256 value);

  event WithdrawToInvest(
    address indexed user,
    uint256 hourly,
    uint256 referrals,
    uint256 gift
  );

  event InvestFree(address indexed user, uint256 value);

  event Invest3Month(
    address indexed user,
    address indexed referrer,
    uint256 value
  );

  event Invest6Month(
    address indexed user,
    address indexed referrer,
    uint256 value
  );

  event UpgradeToMonthly(address indexed user, uint256 value);

  function investFree() external payable;

  function invest3Month(address referrer, uint256 gift) external payable;

  function invest6Month(address referrer, uint256 gift) external payable;

  function upgradeToMonthly(
    uint256 index,
    uint256 gift,
    bool six
  ) external;

  function withdrawInvest(uint256 index) external;

  function withdrawInterest() external;

  function withdrawToInvest(uint256 gift, bool six) external;

  function calculateInterest(address user)
    external
    view
    returns (
      uint256 hourly,
      uint256 referral,
      uint256 gift,
      uint256 requestTime
    );

  function BNBPrice() external view returns (uint256);

  function BNBtoUSD(uint256 value) external view returns (uint256);

  function USDtoBNB(uint256 value) external view returns (uint256);

  function BNBValue(address user) external view returns (uint256);

  function userDepositNumber(address user) external view returns (uint256);

  function userDepositDetails(address user, uint256 index)
    external
    view
    returns (
      uint256 amount,
      uint256 period,
      uint256 reward,
      uint256 startTime,
      uint256 endTime
    );

  function userInvestDetails(address user)
    external
    view
    returns (IUserData.Invest[] memory);

  function userInvestExpired(address user, uint256 index)
    external
    returns (bool);

  function userMaxMonth(address user) external view returns (uint256);

  function users(address user)
    external
    view
    returns (
      address referrer,
      uint256 refAmount,
      uint256 giftAmount,
      uint256 latestWithdraw
    );
}
