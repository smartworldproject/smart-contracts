// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Secure is Context {
  address public owner;

  event AddedBlackList(address user);
  event RemovedBlackList(address user);

  mapping(address => bool) public blacklist;

  modifier onlyOwner() {
    require(_msgSender() == owner, "Error::SmartInvest02, Only from owner!");
    _;
  }

  modifier notBlackListed() {
    require(!blacklist[_msgSender()], "Error::SmartInvest02, User blacklisted!");
    _;
  }

  function addBlackList(address user) public onlyOwner {
    blacklist[user] = true;
    emit AddedBlackList(user); //event emmiting
  }

  function removeBlackList(address user) public onlyOwner {
    blacklist[user] = false;
    emit RemovedBlackList(user);
  }
}
