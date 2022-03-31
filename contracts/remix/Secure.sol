// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Secure is Context {
  address public owner;
  uint256 public FEE = 5000;
  uint256 public LEVEL = 80;
  uint256 public MONTH = 720;
  uint256 public REFERRAL_PERCENT = 100;
  uint256 public BASE_REWARD_PERCENT = 5000;
  uint256 public MINIMUM_INVEST = 5000000000;

  event AddedBlackList(address user);
  event RemovedBlackList(address user);

  modifier onlyOwner() {
    require(_msgSender() == owner, "Error::SmartInvest03, Only from owner!");
    _;
  }

  modifier notBlackListed() {
    require(!blacklist[_msgSender()], "Error::SmartInvest03, User blacklisted!");
    _;
  }

  mapping(address => bool) public blacklist;

  function _safeTransferBNB(address to, uint256 value) internal {
    (bool success, ) = to.call{gas: 23000, value: value}("");

    require(success, "Error::SmartInvest03, BNB Transfer Failed!");
  }

  function changeFee(uint256 fee) public onlyOwner {
    FEE = fee;
  }

  function changeMonth(uint256 month) public onlyOwner {
    MONTH = month;
  }

  function changeLevel(uint256 level) public onlyOwner {
    LEVEL = level;
  }

  function changePercent(uint256 percent) public onlyOwner {
    REFERRAL_PERCENT = percent;
  }

  function changeMinimumAmount(uint256 amount) public onlyOwner {
    MINIMUM_INVEST = amount;
  }

  function changeMinimumRewardPercent(uint256 percent) public onlyOwner {
    BASE_REWARD_PERCENT = percent;
  }

  function addBlackList(address user) public onlyOwner {
    blacklist[user] = true;
    emit AddedBlackList(user);
  }

  function removeBlackList(address user) public onlyOwner {
    blacklist[user] = false;
    emit RemovedBlackList(user);
  }

  function withdrawBnb(uint256 value) public onlyOwner {
    payable(owner).transfer(value);
  }
}
