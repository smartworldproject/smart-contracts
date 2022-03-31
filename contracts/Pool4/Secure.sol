// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Secure is Context {
  event AddedBlackList(address user);
  event RemovedBlackList(address user);

  bool private locked;

  address public owner;
  uint256 public END_TIME;
  uint256 public REWARD = 5;
  uint256 public REFERRAL = 1000;
  uint256 public MAX_SLIPPAGE = 50;

  mapping(address => bool) public blacklist;

  modifier onlyOwner() {
    require(_msgSender() == owner, "Error::SmartPool02, Only from owner!");
    _;
  }

  modifier notBlackListed() {
    require(!blacklist[_msgSender()], "Error::SmartPool02, User blacklisted!");
    _;
  }

  modifier notLocked() {
    require(!locked, "Error::SmartPool02, Deposit is not available!");
    require(!blacklist[_msgSender()], "Error::SmartPool02, User blacklisted!");
    require(END_TIME > block.timestamp, "Error::SmartPool02, Season ended!");
    _;
  }

  modifier ensure(uint256 deadline) {
    require(deadline >= block.timestamp, "Error::SmartPool02, Transaction exapired!");
    _;
  }

  function changeReferral(uint256 percent) external onlyOwner {
    REFERRAL = percent;
  }

  function changeReward(uint256 percent) external onlyOwner {
    REWARD = percent;
  }

  function changeMax(uint256 percent) external onlyOwner {
    MAX_SLIPPAGE = percent;
  }

  function changeEndTime(uint256 end) external onlyOwner {
    END_TIME = end;
  }

  function removeBlackList(address user) public onlyOwner {
    blacklist[user] = false;
    emit RemovedBlackList(user);
  }

  function addBlackList(address user) public onlyOwner {
    blacklist[user] = true;
    emit AddedBlackList(user);
  }

  function lock() external onlyOwner {
    locked = true;
  }

  function unlock() external onlyOwner {
    locked = false;
  }

  bytes4 private constant TRANSFER = bytes4(keccak256(bytes("transfer(address,uint256)")));
  bytes4 private constant APPROVE = bytes4(keccak256(bytes("approve(address,uint256)")));
  bytes4 private constant TRANSERFROM =
    bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));

  function _safeApprove(
    address _token,
    address _spender,
    uint256 _value
  ) internal {
    (bool success, bytes memory data) =
      _token.call(abi.encodeWithSelector(APPROVE, _spender, _value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "Error::SmartPool02, Approve Failed"
    );
  }

  function _safeTransfer(
    address _token,
    address _to,
    uint256 _value
  ) internal {
    (bool success, bytes memory data) =
      _token.call(abi.encodeWithSelector(TRANSFER, _to, _value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "Error::SmartPool02, Transfer Failed"
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
      "Error::SmartPool02, Transfer Failed"
    );
  }

  function _safeTransferBNB(address to, uint256 value) internal {
    (bool success, ) = to.call{gas: 23000, value: value}("");

    require(success, "Error::SmartPool02: BNB Transfer Failed");
  }
}
