// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IPlan {
  // Calculate functions
  function valueIsEnough(uint256 value) external view returns (bool);

  function valueMinusFee(uint256 value) external view returns (uint256);

  function valuePlusBonus(uint256 value, bool max) external view returns (uint256);

  function calcPeriod(bool six) external view returns (uint256);

  function calcPercent(uint256 value) external view returns (uint256);

  function monthlyReward(uint256 value) external view returns (uint256);

  function hourlyReward(uint256 value) external view returns (uint256);

  function freeDailyReward(uint256 value) external view returns (uint256);

  function freeHourlyReward(uint256 value) external view returns (uint256);

  function calcRefValue(uint256 value, uint256 maxPeriod) external view returns (uint256);
}
