// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract STT is ERC20 {
  function decimals() public pure override returns (uint8) {
    return 8;
  }
}
