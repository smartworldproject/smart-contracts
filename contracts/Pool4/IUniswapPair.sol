// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapPair {
  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);
}
