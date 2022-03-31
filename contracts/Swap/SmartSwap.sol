// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ISmartWorld.sol";
import "./ISmartSwap.sol";
import "./Secure.sol";

contract SmartSwap is Secure, ISmartSwap {
  using SafeMath for uint256;

  IUniswapV2Router01 internal UniswapRouter;
  ISmartWorld internal SmartWorld;

  address public constant STT = 0x75Bea6460fff60FF789F88f7FE005295B8901455;
  address public constant STTS = 0xBFd0Ac6cD15712E0a697bDA40897CDc54b06D7Ef;
  address public constant ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

  uint256 public MIN_PERCENT = 500;
  uint256 public MAX_PERCENT = 10000;

  constructor() {
    UniswapRouter = IUniswapV2Router01(ROUTER);
    SmartWorld = ISmartWorld(STT);
    owner = _msgSender();
    _safeApprove(STTS, ROUTER, type(uint256).max);
  }

  function calculateSlippage(uint256 amounts1, uint256 amounts2)
    public
    view
    override
    returns (uint256)
  {
    if (amounts1 > amounts2) {
      return amounts1.sub(amounts2).mul(MAX_PERCENT).div(amounts1);
    } else {
      return amounts2.sub(amounts1).mul(MAX_PERCENT).div(amounts2);
    }
  }

  function setPercentAndApprove(uint256 _percent) public onlyOwner {
    _safeApprove(STTS, ROUTER, type(uint256).max);
    MIN_PERCENT = _percent;
  }

  function safeBnbSwap(
    uint256 amounts,
    uint256 percent,
    uint256 deadline
  ) public payable override ensure(deadline) returns (uint256[] memory) {
    if (msg.value > 0) {
      (uint256 impact, uint256 estimated, , ) = BNBtoSTTSInfo(msg.value, percent);
      require(impact <= MIN_PERCENT, "Error::SmartSwap, Incorrect minimum amounts!");
      return swapExactBNBtoSTTS(estimated, deadline);
    } else if (amounts > 0) {
      (uint256 impact, uint256 estimated, , ) = STTStoBNBInfo(amounts, percent);
      require(impact <= MIN_PERCENT, "Error::SmartSwap, Incorrect minimum amounts!");
      return swapExactSTTStoBNB(amounts, estimated, deadline);
    } else revert("Error::SmartSwap, Incorrect Value!");
  }

  function safeExactBnbSwap(
    uint256 amounts,
    uint256 percent,
    uint256 deadline
  ) public payable override ensure(deadline) returns (uint256[] memory) {
    if (msg.value > 0) {
      (uint256 impact, uint256 estimated, , ) = BNBtoSTTSInfo(msg.value, percent);
      require(impact <= MIN_PERCENT, "Error::SmartSwap, Incorrect minimum amounts!");
      return swapExactBNBtoSTTS(estimated, deadline);
    } else if (amounts > 0) {
      (uint256 impact, uint256 estimated, , ) = STTStoBNBInfo(amounts, percent);
      require(impact <= MIN_PERCENT, "Error::SmartSwap, Incorrect minimum amounts!");
      return swapExactSTTStoBNB(amounts, estimated, deadline);
    } else revert("Error::SmartSwap, Incorrect Value!");
  }

  function swapExactBNBtoSTTS(uint256 minSttsAmount, uint256 deadline)
    public
    payable
    override
    ensure(deadline)
    returns (uint256[] memory amounts)
  {
    amounts = UniswapRouter.swapExactETHForTokens{value: msg.value}(
      minSttsAmount,
      getPathBNBtoSTTS(),
      _msgSender(),
      deadline
    );
    emit SwapBnbForStts(_msgSender(), amounts[0], amounts[amounts.length - 1]);
    return amounts;
  }

  function swapBNBtoExactSTTS(uint256 minSttsAmount, uint256 deadline)
    public
    payable
    override
    ensure(deadline)
    returns (uint256[] memory amounts)
  {
    amounts = UniswapRouter.swapETHForExactTokens{value: msg.value}(
      minSttsAmount,
      getPathBNBtoSTTS(),
      _msgSender(),
      deadline
    );
    emit SwapBnbForStts(_msgSender(), amounts[0], amounts[amounts.length - 1]);
    return amounts;
  }

  function BNBtoSTTSInfo(uint256 bnbAmounts, uint256 percent)
    public
    view
    override
    returns (
      uint256 impact,
      uint256 estimated,
      uint256 min,
      uint256 max
    )
  {
    percent = percent > 0 ? percent : MIN_PERCENT;
    estimated = estimatedBNBtoSTTS(bnbAmounts);
    max = BNBtoSTTSWithoutSlippage(bnbAmounts);
    min = max.mul(uint256(MAX_PERCENT).sub(MIN_PERCENT)).div(MAX_PERCENT);
    impact = calculateSlippage(max, estimated);
  }

  function BNBtoSTTSWithoutSlippage(uint256 bnbAmountIn)
    public
    view
    override
    returns (uint256)
  {
    return BNBtoSTTSPrice().mul(bnbAmountIn).div(10**18);
  }

  function BNBtoSTTSPrice() public view override returns (uint256) {
    return estimatedBNBtoSTTS(10**14).mul(10**4);
  }

  function estimatedBNBtoSTTS(uint256 bnbAmountIn) public view override returns (uint256) {
    uint256[] memory amounts = UniswapRouter.getAmountsOut(bnbAmountIn, getPathBNBtoSTTS());
    return amounts[amounts.length - 1];
  }

  function swapExactSTTStoBNB(
    uint256 sttsAmount,
    uint256 minBnbAmount,
    uint256 deadline
  ) public override ensure(deadline) returns (uint256[] memory amounts) {
    _safeTransferFrom(STTS, _msgSender(), address(this), sttsAmount);
    amounts = UniswapRouter.swapExactTokensForETH(
      sttsAmount,
      minBnbAmount,
      getPathSTTStoBNB(),
      _msgSender(),
      deadline
    );
    emit SwapSttsForBnb(_msgSender(), amounts[0], amounts[amounts.length - 1]);
    return amounts;
  }

  function swapSTTStoExactBNB(
    uint256 sttsAmount,
    uint256 minBnbAmount,
    uint256 deadline
  ) public override ensure(deadline) returns (uint256[] memory amounts) {
    _safeTransferFrom(STTS, _msgSender(), address(this), sttsAmount);
    amounts = UniswapRouter.swapTokensForExactETH(
      sttsAmount,
      minBnbAmount,
      getPathSTTStoBNB(),
      _msgSender(),
      deadline
    );
    emit SwapSttsForBnb(_msgSender(), amounts[0], amounts[amounts.length - 1]);
    return amounts;
  }

  function STTStoBNBInfo(uint256 sttsAmounts, uint256 percent)
    public
    view
    override
    returns (
      uint256 impact,
      uint256 estimated,
      uint256 min,
      uint256 max
    )
  {
    percent = percent > 0 ? percent : MIN_PERCENT;
    estimated = estimatedSTTStoBNB(sttsAmounts);
    max = STTStoBNBWithoutSlippage(sttsAmounts);
    min = max.mul(uint256(MAX_PERCENT).sub(percent)).div(MAX_PERCENT);
    impact = calculateSlippage(max, estimated);
  }

  function STTStoBNBWithoutSlippage(uint256 sttsAmountIn)
    public
    view
    override
    returns (uint256)
  {
    return STTStoBNBPrice().mul(sttsAmountIn).div(10**8);
  }

  function STTStoBNBPrice() public view override returns (uint256) {
    return estimatedSTTStoBNB(10**8);
  }

  function estimatedSTTStoBNB(uint256 sttsAmountIn) public view override returns (uint256) {
    uint256[] memory amounts = UniswapRouter.getAmountsOut(sttsAmountIn, getPathSTTStoBNB());
    return amounts[amounts.length - 1];
  }

  function getPathBNBtoSTTS() private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = UniswapRouter.WETH();
    path[1] = STTS;
    return path;
  }

  function getPathSTTStoBNB() private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = STTS;
    path[1] = UniswapRouter.WETH();
    return path;
  }

  // STT swap -----------------------------------------------

  function STTStoSTTPrice() public view override returns (uint256) {
    return SmartWorld.sttsToSatoshi(10**16).div(SmartWorld.sttPrice());
  }

  function safeSTTSwap(
    uint256 sttAmount,
    uint256 sttsAmount,
    uint256 percent,
    uint256 deadline
  ) public override ensure(deadline) returns (uint256[2] memory) {
    (, , uint256 min, uint256 max) = STTtoSTTSInfo(sttAmount, percent);
    require(min <= sttsAmount && sttsAmount <= max, "Error::SmartSwap, Incorrect Value!");
    return swapSTTSforSTT(sttAmount);
  }

  function safeExactSTTSwap(
    uint256 sttsAmount,
    uint256 sttAmount,
    uint256 percent,
    uint256 deadline
  ) public override ensure(deadline) returns (uint256[2] memory) {
    (, , uint256 min, uint256 max) = STTtoSTTSInfo(sttAmount, percent);
    require(min <= sttsAmount && sttsAmount <= max, "Error::SmartSwap, Incorrect Value!");
    return swapExactSTTSforSTT(sttsAmount);
  }

  function swapSTTtoSTTS(
    uint256 sttAmount,
    uint256 minSttsAmount,
    uint256 maxSttsAmount,
    uint256 deadline
  ) public override ensure(deadline) returns (uint256[2] memory amounts) {
    uint256 estimatedStts = estimatedSTTSforSTT(sttAmount);
    require(
      minSttsAmount <= estimatedStts && estimatedStts <= maxSttsAmount,
      "Error::SmartSwap, Incorrect Value!"
    );
    return swapSTTSforSTT(sttAmount);
  }

  function swapSTTforExactSTTS(
    uint256 sttsAmount,
    uint256 minSttAmount,
    uint256 maxSttAmount,
    uint256 deadline
  ) public override ensure(deadline) returns (uint256[2] memory amounts) {
    uint256 estimatedStt = estimatedSTTforExactSTTS(sttsAmount);
    require(
      minSttAmount <= estimatedStt && estimatedStt <= maxSttAmount,
      "Error::SmartSwap, Incorrect Value!"
    );
    return swapExactSTTSforSTT(sttsAmount);
  }

  function STTtoSTTSInfo(uint256 sttAmounts, uint256 percent)
    public
    view
    override
    returns (
      uint256 impact,
      uint256 estimated,
      uint256 min,
      uint256 max
    )
  {
    impact = percent > 0 ? percent : MIN_PERCENT;
    uint256 maxSlippage = estimatedSTTSforSTT(sttAmounts).mul(impact).div(MAX_PERCENT);
    estimated = estimatedSTTSforSTT(sttAmounts);
    min = estimated.sub(maxSlippage);
    max = estimated.add(maxSlippage);
  }

  function estimatedSTTSforSTT(uint256 sttAmountIn) public view override returns (uint256) {
    return sttAmountIn.mul(10**8).div(STTStoSTTPrice());
  }

  function estimatedSTTforExactSTTS(uint256 sttsAmountIn)
    public
    view
    override
    returns (uint256)
  {
    return sttsAmountIn.mul(STTStoSTTPrice()).div(10**8);
  }

  function swapSTTSforSTT(uint256 sttAmount) internal returns (uint256[2] memory amounts) {
    uint256 sttsAmount = estimatedSTTSforSTT(sttAmount);
    require(
      SmartWorld.burnWithStt(_msgSender(), sttAmount),
      "Error::SmartSwap, STT Burn failed!"
    );
    _safeTransfer(STTS, _msgSender(), sttsAmount);
    emit SwapSttForStts(_msgSender(), sttAmount, sttsAmount);
    return [sttAmount, sttsAmount];
  }

  function swapExactSTTSforSTT(uint256 sttsAmount)
    internal
    returns (uint256[2] memory amounts)
  {
    uint256 sttAmount = estimatedSTTforExactSTTS(sttsAmount);
    require(
      SmartWorld.burnWithStt(_msgSender(), sttAmount),
      "Error::SmartSwap, STT Burn failed!"
    );
    _safeTransfer(STTS, _msgSender(), sttsAmount);
    emit SwapSttForStts(_msgSender(), sttAmount, sttsAmount);
    return [sttAmount, sttsAmount];
  }

  function sendSTTStoOwner(uint256 sttsAmount) public onlyOwner {
    _safeTransfer(STTS, owner, sttsAmount);
  }

  function sendBNBtoOwner(uint256 value) public onlyOwner {
    payable(owner).transfer(value);
  }

  receive() external payable {}
}
