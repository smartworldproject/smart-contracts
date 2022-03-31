// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISmartInvest03 {
  event UpdateUser(address indexed user, uint256 value);
  event RefreshUser(address indexed user, uint256 value);
  event Migration(address indexed user, address indexed referrer, uint256 value);
  event WithdrawInterest(address indexed user, uint256 hourly, uint256 referrals);
  event RegisterUser(address indexed user, address indexed referrer, uint256 value);

  function maxPercent() external view returns (uint256);

  function totalReward(uint256 value) external view returns (uint256);

  function rewardPercent(uint256 value) external view returns (uint256);

  function monthlyReward(uint256 value) external view returns (uint256);

  function hourlyReward(uint256 value) external view returns (uint256);

  function rewardPeriod(uint256 value) external view returns (uint256);

  function rewardInfo(uint256 value)
    external
    view
    returns (
      uint256 period,
      uint256 reward,
      uint256 endTime
    );

  function btcPrice() external view returns (uint256);

  function sttsToUSD(uint256 value) external view returns (uint256);

  function bnbToUSD(uint256 value) external view returns (uint256);

  function btcToUSD(uint256 value) external view returns (uint256);

  function sttsToUSDPrice() external view returns (uint256);

  function USDToStts(uint256 value) external view returns (uint256);

  function referralInfo(address user, uint256 value)
    external
    view
    returns (uint256 totalAmount, uint256 refPercent);

  function migrateByAdmin(address user) external returns (bool);

  function migrateByUser() external returns (bool);

  function investBnb(address referrer) external payable returns (bool);

  function investStts(address referrer, uint256 value) external returns (bool);

  function investBtcb(address referrer, uint256 value) external returns (bool);

  function updateBnb() external payable returns (bool);

  function updateStts(uint256 value) external returns (bool);

  function updateBtcb(uint256 value) external returns (bool);

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
    returns (uint256 hourly);

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

  function userExpired(address user) external view returns (bool);
}
