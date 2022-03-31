// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Secure is Context {
  address public owner;

  modifier onlyOwner() {
    require(_msgSender() == owner, "Error::SmartPool, Only from owner!");
    _;
  }

  modifier ensure(uint256 deadline) {
    require(deadline >= block.timestamp, "Error::SmartPool, Swap Exapired!");
    _;
  }

  function _safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{value: value}(new bytes(0));
    require(success, "TransferHelper: ETH_TRANSFER_FAILED");
  }
}
