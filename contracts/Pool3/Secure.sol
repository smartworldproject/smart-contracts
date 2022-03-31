// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Secure is Context {
  address public owner;
  bool private locked;

  modifier onlyOwner() {
    require(_msgSender() == owner, "Error::SmartPool, Only from owner!");
    _;
  }

  modifier notLocked() {
    require(!locked, "Error::SmartPool, Deposit is not available!");
    _;
  }

  modifier ensure(uint256 deadline) {
    require(deadline >= block.timestamp, "Error::SmartPool, Transaction exapired!");
    _;
  }

  function toggleLock() external onlyOwner {
    locked = !locked;
  }
}
