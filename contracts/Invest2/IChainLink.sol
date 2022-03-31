// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IChainLink {
  function latestAnswer() external view returns (int256 answer);
}
