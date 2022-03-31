// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISmartSwap {
  event SwapSttsForBnb(address indexed user, uint256 amountIn, uint256 amountOut);

  event SwapBnbForStts(address indexed user, uint256 amountIn, uint256 amountOut);

  event SwapSttForStts(address indexed user, uint256 amountIn, uint256 amountOut);

  function calculateSlippage(uint256 totalAmount, uint256 amounts)
    external
    view
    returns (uint256);

  function safeBnbSwap(
    uint256 paymentAmountIn,
    uint256 percent,
    uint256 deadline
  ) external payable returns (uint256[] memory);

  function safeExactBnbSwap(
    uint256 paymentAmountIn,
    uint256 percent,
    uint256 deadline
  ) external payable returns (uint256[] memory);

  function swapExactBNBtoSTTS(uint256 minSttsAmount, uint256 deadline)
    external
    payable
    returns (uint256[] memory amounts);

  function swapBNBtoExactSTTS(uint256 minSttsAmount, uint256 deadline)
    external
    payable
    returns (uint256[] memory amounts);

  function BNBtoSTTSInfo(uint256 bnbAmounts, uint256 percent)
    external
    returns (
      uint256 slippage,
      uint256 allowed,
      uint256 min,
      uint256 max
    );

  function BNBtoSTTSWithoutSlippage(uint256 bnbAmountIn) external view returns (uint256);

  function BNBtoSTTSPrice() external view returns (uint256);

  function estimatedBNBtoSTTS(uint256 bnbAmountIn) external view returns (uint256);

  function swapExactSTTStoBNB(
    uint256 sttsAmount,
    uint256 minBnbAmount,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapSTTStoExactBNB(
    uint256 sttsAmount,
    uint256 minBnbAmount,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function STTStoBNBInfo(uint256 sttsAmounts, uint256 percent)
    external
    returns (
      uint256 slippage,
      uint256 allowed,
      uint256 min,
      uint256 max
    );

  function STTStoBNBWithoutSlippage(uint256 sttsAmountIn) external view returns (uint256);

  function STTStoBNBPrice() external view returns (uint256);

  function estimatedSTTStoBNB(uint256 sttsAmountIn) external view returns (uint256);

  function safeSTTSwap(
    uint256 paymentAmountIn,
    uint256 minSttsAmount,
    uint256 percent,
    uint256 deadline
  ) external returns (uint256[2] memory);

  function safeExactSTTSwap(
    uint256 sttAmount,
    uint256 sttsAmount,
    uint256 percent,
    uint256 deadline
  ) external returns (uint256[2] memory);

  function swapSTTtoSTTS(
    uint256 sttAmountIn,
    uint256 minSttsAmount,
    uint256 maxSttsAmount,
    uint256 deadline
  ) external returns (uint256[2] memory amounts);

  function swapSTTforExactSTTS(
    uint256 sttAmount,
    uint256 minSttsAmount,
    uint256 maxSttsAmount,
    uint256 deadline
  ) external returns (uint256[2] memory amounts);

  function STTtoSTTSInfo(uint256 sttAmounts, uint256 percent)
    external
    view
    returns (
      uint256 slippage,
      uint256 allowed,
      uint256 min,
      uint256 max
    );

  function estimatedSTTSforSTT(uint256 sttAmountIn) external view returns (uint256);

  function estimatedSTTforExactSTTS(uint256 sttsAmountIn) external view returns (uint256);

  function STTStoSTTPrice() external view returns (uint256);
}
