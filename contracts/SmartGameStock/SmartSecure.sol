// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract SmartSecure {
  address public owner;

  modifier onlyOwner() {
    require(_msgSender() == owner, "OWN");
    _;
  }

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  bytes4 private constant BALANCE = bytes4(keccak256(bytes("balanceOf(address)")));
  bytes4 private constant TRANSFER = bytes4(keccak256(bytes("transfer(address,uint256)")));
  bytes4 private constant TRANSERFROM =
    bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));

  function _balanceOf(address _token, address _user) internal view returns (uint256) {
    (, bytes memory data) = _token.staticcall(abi.encodeWithSelector(BALANCE, _user));
    return abi.decode(data, (uint256));
  }

  function _safeTransfer(
    address _token,
    address _to,
    uint256 _value
  ) internal {
    (bool success, bytes memory data) = _token.call(
      abi.encodeWithSelector(TRANSFER, _to, _value)
    );
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "Error::GameStock, Transfer Failed!"
    );
  }

  function _safeTransferFrom(
    address _token,
    address _from,
    address _to,
    uint256 _value
  ) internal {
    (bool success, bytes memory data) = _token.call(
      abi.encodeWithSelector(TRANSERFROM, _from, _to, _value)
    );
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "Error::GameStock, Transfer From Failed!"
    );
  }

  function withdrawToken(address token, uint256 value) external onlyOwner {
    _safeTransfer(token, owner, value);
  }
}
