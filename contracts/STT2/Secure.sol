// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Secure is Context {
  using SafeMath for uint256;

  event VoteStarted(address indexed nominate);
  event AuthorizedContract(address indexed nominate);
  event VoteSuccess(address indexed nominate, address indexed voter);

  bytes4 private constant TRANSFER = bytes4(keccak256(bytes("transfer(address,uint256)")));
  bytes4 private constant TRANSERFROM =
    bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));

  struct Elect {
    uint256 value;
    address[] voted;
    address nominate;
  }

  Elect public onVote;

  address public owner;
  address[] public devs;
  mapping(address => bool) public contracts;

  modifier onlyOwner() {
    require(_msgSender() == owner, "Secure:: Only from owner!");
    _;
  }

  modifier onlyFromContract() {
    require(contracts[_msgSender()], "Secure:: Only from contract!");
    _;
  }

  modifier voteByDevs(uint256 _value) {
    require(isDeveloper(_msgSender()), "Secure:: Only from devs!");
    require(_value == onVote.value, "Secure:: You are voting for wrong nominate!");
    require(notVoted(_msgSender()), "Secure:: You already vote for this nominate!");
    address smartContract = onVote.nominate;
    require(smartContract != address(0), "Secure:: Nothing to vote!");
    if (onVote.voted.length == devs.length.sub(1)) {
      _;
      delete onVote;
    } else {
      onVote.voted.push(_msgSender());
      emit VoteSuccess(smartContract, _msgSender());
    }
  }

  function startVote(address nominate, uint256 value) public onlyOwner {
    delete onVote;
    if (value == 0) require(isContract(nominate), "Nominate is not contract!");
    onVote.nominate = nominate;
    onVote.value = value;
    emit VoteStarted(nominate);
  }

  function totalVote() public view returns (uint256) {
    return onVote.voted.length;
  }

  function notVoted(address voter) public view returns (bool) {
    for (uint256 i = 0; i < onVote.voted.length; i++) {
      if (onVote.voted[i] == voter) {
        return false;
      }
    }
    return true;
  }

  function authorizeContract() public voteByDevs(0) {
    require(onVote.value == 0, "Secure:: Nothing on the Vote!");
    address smartContract = onVote.nominate;
    contracts[smartContract] = !contracts[smartContract];
    emit AuthorizedContract(smartContract);
  }

  function isDeveloper(address account) public view returns (bool) {
    for (uint256 i = 0; i < devs.length; i++) {
      if (devs[i] == account) {
        return true;
      }
    }
    return false;
  }

  function isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
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
