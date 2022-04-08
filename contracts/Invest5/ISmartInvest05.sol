// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISmartInvest05 {
  event UpdateUser(address indexed user, uint256 value);
  event WithdrawInterest(address indexed user, uint256 hourly, uint256 referrals);
  event RegisterUser(address indexed user, address indexed referrer, uint256 value);

  function monthlyReward(uint256 value) external view returns (uint256);

  function hourlyReward(uint256 value) external view returns (uint256);

  function BNBtoUSD(uint256 value) external view returns (uint256);

  function BNBtoUSDWithFee(uint256 value) external view returns (uint256);

  function USDtoBNB(uint256 value) external view returns (uint256);

  function BNBPrice() external view returns (uint256);

  function refMultiplier(address user, uint8 level) external view returns (uint256);

  function invest(address referrer) external payable returns (bool);

  function withdrawInterest() external returns (bool);

  function calculateInterest(address user)
    external
    view
    returns (
      uint256 hourly,
      uint256 referral,
      uint256 requestTime
    );

  function calculateHourly(address sender, uint256 time)
    external
    view
    returns (uint256 current, uint256 past);

  function userDepositNumber(address user) external view returns (uint256);

  function userDepositDetails(address user, uint256 index)
    external
    view
    returns (
      uint256 amount,
      uint256 reward,
      uint256 startTime,
      uint256 endTime
    );

  function userListLength() external view returns (uint256);

  function userList(uint256 index) external view returns (address);

  function users(address user)
    external
    view
    returns (
      address referrer,
      uint256 refAmounts,
      uint256 totalAmount,
      uint256 latestWithdraw
    );
}
