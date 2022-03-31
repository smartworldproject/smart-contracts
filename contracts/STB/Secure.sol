// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Secure is Context {
  address public owner;

  modifier onlyOwner() {
    require(_msgSender() == owner, "Error::SmartPool, Only from owner!");
    _;
  }

  modifier ensure(uint256 deadline) {
    require(deadline >= block.timestamp, "Error::SmartWorldBits, Generate Exapired!");
    _;
  }

  bytes4 private constant TRANSFER = bytes4(keccak256(bytes("transfer(address,uint256)")));
  bytes4 private constant TRANSERFROM =
    bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));

  function _safeTransfer(
    address _token,
    address _to,
    uint256 _value
  ) internal {
    (bool success, bytes memory data) =
      _token.call(abi.encodeWithSelector(TRANSFER, _to, _value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "Error::SmartWorld, Transfer Failed"
    );
  }

  function _safeTransferFrom(
    address _token,
    address _from,
    address _to,
    uint256 _value
  ) internal {
    (bool success, bytes memory data) =
      _token.call(abi.encodeWithSelector(TRANSERFROM, _from, _to, _value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "Error::SmartWorld, Transfer Failed"
    );
  }
}
