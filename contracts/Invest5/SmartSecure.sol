// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract SmartSecure {
  event AddedBlackList(address indexed user);
  event RemovedBlackList(address indexed user);

  bool internal locked;

  address public owner;

  uint16 public FEE = 5000;
  uint16 public MONTHLY_REWARD_PERCENT = 5000;

  uint8 public REFERRAL_LEVEL = 50;
  uint32 public REFERRAL_PERCENT = 100000;

  uint64 public MINIMUM_INVEST = 5000000000;
  uint64 public MAXIMUM_INVEST = 50000000000;

  mapping(address => bool) public blacklist;

  modifier onlyOwner() {
    require(_msgSender() == owner, "OWN");
    _;
  }

  modifier secured() {
    require(!blacklist[_msgSender()], "BLK");
    require(!locked, "REN");
    locked = true;
    _;
    locked = false;
  }

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{gas: 23000, value: value}("");

    require(success, "ETH");
  }

  function changeMonthlyRewardPercent(uint16 percent) external onlyOwner {
    MONTHLY_REWARD_PERCENT = percent;
  }

  function changeReferralPercent(uint32 percent) external onlyOwner {
    REFERRAL_PERCENT = percent;
  }

  function changeReferralLevel(uint8 level) external onlyOwner {
    REFERRAL_LEVEL = level;
  }

  function changeMinimumInvest(uint64 amount) external onlyOwner {
    MINIMUM_INVEST = amount;
  }

  function changeMaximumInvest(uint64 amount) external onlyOwner {
    MAXIMUM_INVEST = amount;
  }

  function changeFee(uint16 fee) external onlyOwner {
    FEE = fee;
  }

  function addBlackList(address user) external onlyOwner {
    blacklist[user] = true;
    emit AddedBlackList(user);
  }

  function removeBlackList(address user) external onlyOwner {
    blacklist[user] = false;
    emit RemovedBlackList(user);
  }

  function withdrawBnb(uint256 value) external onlyOwner {
    payable(owner).transfer(value);
  }
}
