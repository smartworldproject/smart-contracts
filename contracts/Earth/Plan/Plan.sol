// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IPlan.sol";
import "./Math.sol";

contract Plan is IPlan, Ownable {
  using Math for uint256;

  uint16 public FEE;

  uint16 public BONUS_MIN = 5_00;
  uint16 public BONUS_MAX = 10_00;

  uint16 public REFERRAL_MIN = 5_00;
  uint16 public REFERRAL_MAX = 10_00;

  uint16 public REWARD_PERCENT = 20;

  uint16 public HUNDRED_PERCENT = 100_00;

  uint32 public MINIMUM_PERIOD = 90 days;
  uint32 public MAXIMUM_PERIOD = 180 days;

  uint64 public MINIMUM_INVEST = 50 * 10**8;

  uint16[20] public PERCENTAGE = [
    20_00,
    25_00,
    30_00,
    35_00,
    40_00,
    42_50,
    45_00,
    47_50,
    50_00,
    52_00,
    54_00,
    56_00,
    57_50,
    59_00,
    60_00,
    61_00,
    62_00,
    63_00,
    64_00,
    65_00
  ];

  uint24[20] public FIAT = [
    50,
    2000,
    5000,
    10_000,
    15_000,
    20_000,
    30_000,
    40_000,
    50_000,
    65_000,
    80_000,
    100_000,
    150_000,
    200_000,
    300_000,
    400_000,
    500_000,
    650_000,
    800_000,
    1_000_000
  ];

  // Calculate functions
  function valueIsEnough(uint256 value) public view override returns (bool) {
    return value >= MINIMUM_INVEST;
  }

  function valueMinusFee(uint256 value) public view override returns (uint256) {
    uint256 fee = value.mul(FEE).div(HUNDRED_PERCENT);
    return value.sub(fee);
  }

  function valuePlusBonus(uint256 value, bool max) public view override returns (uint256) {
    uint256 bonus = value.mul(max ? BONUS_MAX : BONUS_MIN).div(HUNDRED_PERCENT);
    return value.add(bonus);
  }

  function calcPeriod(bool six) public view override returns (uint256) {
    return six ? MAXIMUM_PERIOD : MINIMUM_PERIOD;
  }

  function calcPercent(uint256 value) public view override returns (uint256) {
    uint8 index;
    if (value < MINIMUM_INVEST) return index;
    uint256 val = value.divDecimals(8);
    for (uint8 i = 0; i < FIAT.length; i++) {
      if (val >= FIAT[i]) index = i;
    }
    return PERCENTAGE[index];
  }

  function monthlyReward(uint256 value) public view override returns (uint256) {
    uint256 percent = calcPercent(value);
    return value.mul(percent).div(HUNDRED_PERCENT);
  }

  function hourlyReward(uint256 value) public view override returns (uint256) {
    return monthlyReward(value).div(720);
  }

  function freeDailyReward(uint256 value) public view override returns (uint256) {
    if (value < MINIMUM_INVEST) return 0;
    return value.mul(REWARD_PERCENT).div(HUNDRED_PERCENT);
  }

  function freeHourlyReward(uint256 value) public view override returns (uint256) {
    return freeDailyReward(value).div(24);
  }

  function calcRefValue(uint256 value, uint256 userPeriod)
    public
    view
    override
    returns (uint256)
  {
    uint256 refPercent = userPeriod >= MAXIMUM_PERIOD
      ? REFERRAL_MAX
      : userPeriod >= MINIMUM_PERIOD
      ? REFERRAL_MIN
      : 0;
    return value.mul(refPercent).div(HUNDRED_PERCENT);
  }

  // Modifier functions ------------------------------------------------
  function changeFee(uint16 fee) external onlyOwner {
    FEE = fee;
  }

  function changeMaxReferral(uint16 value) external onlyOwner {
    REFERRAL_MAX = value;
  }

  function changeMinReferral(uint16 value) external onlyOwner {
    REFERRAL_MIN = value;
  }

  function changeMaxBonusPercent(uint16 percent) external onlyOwner {
    BONUS_MAX = percent;
  }

  function changeMinBonusPercent(uint16 percent) external onlyOwner {
    BONUS_MIN = percent;
  }

  function changeHundredPercent(uint16 percent) external onlyOwner {
    HUNDRED_PERCENT = percent;
  }

  function changeRewardPercent(uint16 percent) external onlyOwner {
    REWARD_PERCENT = percent;
  }

  function changeMaxPeriod(uint32 period) external onlyOwner {
    MAXIMUM_PERIOD = period;
  }

  function changeMinPeriod(uint32 period) external onlyOwner {
    MINIMUM_PERIOD = period;
  }

  function changeMinInvest(uint64 amount) external onlyOwner {
    MINIMUM_INVEST = amount;
  }

  function changeFiat(uint24[20] memory fiat) external onlyOwner {
    FIAT = fiat;
  }

  function changePercentage(uint16[20] memory percentage) external onlyOwner {
    PERCENTAGE = percentage;
  }
}
