// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Secure is Context {
  address public owner;
  uint256 public LEVEL = 80;
  uint256 public MONTH = 720;
  uint256 public PERCENT = 100;

  event AddedBlackList(address user);
  event RemovedBlackList(address user);

  modifier onlyOwner() {
    require(_msgSender() == owner, "Error::SmartInvest02, Only from owner!");
    _;
  }

  modifier notBlackListed() {
    require(!blacklist[_msgSender()], "Error::SmartInvest02, User blacklisted!");
    _;
  }

  mapping(address => bool) public blacklist;

  bytes4 private constant TRANSFER = bytes4(keccak256(bytes("transfer(address,uint256)")));

  function _safeTransfer(
    address _token,
    address _to,
    uint256 _value
  ) internal {
    (bool success, bytes memory data) =
      _token.call(abi.encodeWithSelector(TRANSFER, _to, _value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "Error::SmartInvest02, Transfer Failed"
    );
  }

  function changeMonth(uint256 month) public onlyOwner {
    MONTH = month;
  }

  function changeLevel(uint256 level) public onlyOwner {
    LEVEL = level;
  }

  function changePercent(uint256 percent) public onlyOwner {
    PERCENT = percent;
  }

  function addBlackList(address user) public onlyOwner {
    blacklist[user] = true;
    emit AddedBlackList(user);
  }

  function removeBlackList(address user) public onlyOwner {
    blacklist[user] = false;
    emit RemovedBlackList(user);
  }
}
