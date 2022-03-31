// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISmartWorld {
  function sttPrice() external view returns (uint256);

  function sttsToBnbPrice() external view returns (uint256);

  function sttsToBnb(uint256 value_) external view returns (uint256);

  function deposit(address sender_, uint256 value_) external payable returns (bool);

  function activation(address sender_, uint256 airDrop_) external returns (bool);

  function payWithStt(address reciever_, uint256 interest_) external returns (bool);
}
