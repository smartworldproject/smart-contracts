// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISmartWorldBits {
  event GenerateWithSTT(address _reciever, uint256 _amount);

  event GenerateWithBTC(address _reciever, uint256 _amount);

  function STTtoSTBPrice() external view returns (uint256 stbPrice);

  function STBtoSTT(uint256 stbAmount) external view returns (uint256 sttAmount);

  function STTtoSTB(uint256 sttAmount) external view returns (uint256 stbAmount);

  function generateFromSTT(
    uint256 sttAmount,
    uint256 minStbAmount,
    uint256 deadline
  ) external returns (uint256 stbAmount);

  function BTCtoSTBPrice() external view returns (uint256 stbPrice);

  function STBtoBTC(uint256 stbAmount) external view returns (uint256 btcAmount);

  function BTCtoSTB(uint256 btcAmount) external view returns (uint256 stbAmount);

  function generateFromBTC(uint256 btcAmount, uint256 deadline)
    external
    returns (uint256 stbAmount);
}
