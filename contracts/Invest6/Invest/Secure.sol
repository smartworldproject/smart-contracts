// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Secure is Ownable {
  bool internal locked;

  bytes4 private constant TRANSFER =
    bytes4(keccak256(bytes("transfer(address,uint256)")));

  function _safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{ gas: 23000, value: value }("");

    require(success, "TREE::ETH");
  }

  function _safeTransfer(
    address token,
    address to,
    uint256 value
  ) internal {
    (bool success, bytes memory data) = token.call(
      abi.encodeWithSelector(TRANSFER, to, value)
    );
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "TREE::TTF"
    );
  }

  function pause() external onlyOwner {
    require(!locked);
    locked = true;
  }

  function unpause() external onlyOwner {
    require(locked);
    locked = false;
  }

  function withdrawBnb(uint256 value) external onlyOwner {
    payable(owner()).transfer(value);
  }

  function withdrawToken(address token, uint256 value) external onlyOwner {
    _safeTransfer(token, owner(), value);
  }
}
