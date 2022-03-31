// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @dev Extension of {ERC20} that adds a cap to the supply of tokens.
 */
contract STTS is ERC20 {
  uint256 private immutable _cap;

  /**
   * @dev Sets the value of the `cap`. This value is immutable, it can only be
   * set once during construction.
   */
  constructor() ERC20("Smart World Token - Stock", "STTS") {
    uint256 cap_ = 100000000 * 10**8;
    _cap = cap_;
    super._mint(msg.sender, cap_);
  }

  function decimals() public view virtual override returns (uint8) {
    return 8;
  }

  /*
   * @dev Returns the cap on the token's total supply.
   */
  function cap() public view virtual returns (uint256) {
    return _cap;
  }
}
