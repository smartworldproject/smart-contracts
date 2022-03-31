// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ISmartWorldBits.sol";
import "./ISmartWorld.sol";
import "./Secure.sol";
import "./STB.sol";

contract SmartWorldBits is STB, ISmartWorldBits, Secure {
  using SafeMath for uint256;

  uint256 internal constant DECIMALS = 10**8;
  uint256 internal constant BITS_PRICE = 100 * DECIMALS;
  uint256 internal constant BTCB_PRICE = 100 * BITS_PRICE;

  ISmartWorld internal SmartWorld;

  address public constant STT = 0x75Bea6460fff60FF789F88f7FE005295B8901455;
  address public constant BTCB = 0x3c26729bb1Cf37d18EFdF3bb957f5e0de5c2Cb12;

  constructor() ERC20("Smart World Bits", "STB") {
    SmartWorld = ISmartWorld(STT);
    owner = _msgSender();
  }

  function transferToken(address token, uint256 value) external onlyOwner {
    _safeTransfer(token, owner, value);
  }

  function minusOnePercent(uint256 value) internal pure returns (uint256) {
    return value.sub(value.div(101));
  }

  // Generate STB using STT
  function generateFromSTT(
    uint256 sttAmount,
    uint256 minStbAmount,
    uint256 deadline
  ) public override ensure(deadline) returns (uint256 stbAmount) {
    stbAmount = STTtoSTB(sttAmount);
    require(stbAmount >= minStbAmount, "Error::SmartWorldBits, Wrong minimum amount!");
    _safeTransferFrom(STT, _msgSender(), address(this), sttAmount);
    require(
      SmartWorld.burnWithStt(address(this), minusOnePercent(sttAmount)),
      "Error::SmartWorldBits, STT Burn failed!"
    );
    super._mint(_msgSender(), stbAmount);
    emit GenerateWithSTT(_msgSender(), stbAmount);
  }

  function STBtoSTT(uint256 stbAmount) public view override returns (uint256) {
    return stbAmount.mul(STTtoSTBPrice()).div(DECIMALS);
  }

  function STTtoSTB(uint256 sttAmount) public view override returns (uint256) {
    return sttAmount.mul(DECIMALS).div(STTtoSTBPrice());
  }

  function STTtoSTBPrice() public view override returns (uint256) {
    return BITS_PRICE.mul(101).div(100).div(SmartWorld.sttPrice());
  }

  // Generate STB using BTCB
  function generateFromBTC(uint256 btcAmount, uint256 deadline)
    public
    override
    ensure(deadline)
    returns (uint256 stbAmount)
  {
    _safeTransferFrom(BTCB, _msgSender(), address(this), btcAmount);
    _safeTransfer(BTCB, STT, minusOnePercent(btcAmount));
    stbAmount = BTCtoSTB(btcAmount);
    super._mint(_msgSender(), stbAmount);
    emit GenerateWithBTC(_msgSender(), stbAmount);
  }

  function STBtoBTC(uint256 stbAmount) public pure override returns (uint256) {
    return stbAmount.mul(BTCtoSTBPrice()).div(DECIMALS);
  }

  function BTCtoSTB(uint256 btcAmount) public pure override returns (uint256) {
    return btcAmount.mul(DECIMALS).div(BTCtoSTBPrice());
  }

  function BTCtoSTBPrice() public pure override returns (uint256) {
    return BTCB_PRICE.mul(101).div(100);
  }
}
