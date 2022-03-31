// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISmartWorld {
  function sttPrice() external view returns (uint256);

  function STTS() external view returns (address);

  function BTCB() external view returns (address);

  function totalSupply() external view returns (uint256);

  function sttsToSatoshi(uint256 value_) external view returns (uint256);

  function burnWithStt(address from_, uint256 amount_) external returns (bool);
}
