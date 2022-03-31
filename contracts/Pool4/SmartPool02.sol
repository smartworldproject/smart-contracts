// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IUniswapRouter.sol";
import "./IUniswapPair.sol";
import "./ISmartPool02.sol";
import "./Secure.sol";

contract SmartPool02 is Secure, ISmartPool {
  using SafeMath for uint256;

  struct Deposit {
    uint256 startTime;
    uint256 reward;
  }

  struct UserStruct {
    address referrer;
    uint256 refPercent;
    uint256 refAmounts;
    uint256 liquidity;
    uint256 latestWithdraw;
    Deposit[] deposit;
  }

  address internal WETH;
  address internal constant STTS = 0x88469567A9e6b2daE2d8ea7D8C77872d9A0d43EC;
  address internal constant LPTOKEN = 0x45Ee99347E4E3946bE250fEC8172401965E2DFB3;
  IUniswapRouter internal ROUTER = IUniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

  uint256 internal HUNDRED = 10000;
  uint256 internal MINIMUM_LP = 100_000_000_000;

  mapping(address => UserStruct) public users;

  constructor() {
    owner = _msgSender();
    preApprove();
    WETH = ROUTER.WETH();
    users[owner].referrer = address(LPTOKEN);
    users[owner].latestWithdraw = block.timestamp;
    END_TIME = block.timestamp.add(180 days);
  }

  function sttsToBnbPrice() public view override returns (uint256) {
    (uint112 _reserve0, uint112 _reserve1, ) = IUniswapPair(LPTOKEN).getReserves();
    return uint256(_reserve0).mul(10**18).div(uint256(_reserve1));
  }

  function preApprove() public onlyOwner {
    _safeApprove(STTS, address(ROUTER), ~uint256(0));
  }

  function totalLiquidity() public view override returns (uint256) {
    return IUniswapPair(LPTOKEN).totalSupply();
  }

  function calculateBnb(uint256 stts) public view override returns (uint256) {
    return stts.mul(10**18).div(sttsToBnbPrice());
  }

  function getSttsReserve() internal view returns (uint256) {
    return IERC20(STTS).balanceOf(LPTOKEN);
  }

  function getBnbReserve() internal view returns (uint256) {
    return IERC20(WETH).balanceOf(LPTOKEN);
  }

  function calculateLiquidityValue(uint256 liquidity)
    public
    view
    override
    returns (
      uint256 stts,
      uint256 bnb,
      uint256 total
    )
  {
    total = totalLiquidity();
    stts = getSttsReserve().mul(liquidity).div(total);
    bnb = getBnbReserve().mul(liquidity).div(total);
  }

  function calculateReward(uint256 value) public view override returns (uint256) {
    return value.mul(REWARD).div(HUNDRED);
  }

  function calculateRef(uint256 value) public view override returns (uint256) {
    return value.mul(REFERRAL).div(HUNDRED);
  }

  function calculatePercent(uint256 value, uint256 percent)
    public
    view
    override
    returns (uint256 userValue, uint256 refValue)
  {
    uint256 totalValue = calculateRef(value);
    refValue = totalValue.mul(percent).div(HUNDRED);
    userValue = totalValue.sub(refValue);
  }

  function freezeInfo(uint256 stts, uint256 percent)
    external
    view
    override
    returns (
      uint256 reward,
      uint256 bnb,
      uint256 minStts,
      uint256 minBnb,
      uint256 slippage
    )
  {
    bnb = calculateBnb(stts);
    slippage = percent > 0 ? percent : MAX_SLIPPAGE;
    minStts = stts.mul(HUNDRED.sub(slippage)).div(HUNDRED);
    minBnb = bnb.mul(HUNDRED.sub(slippage)).div(HUNDRED);
    reward = calculateReward(stts);
  }

  function unfreezeInfo(address user, uint256 percent)
    external
    view
    override
    returns (
      uint256 stts,
      uint256 bnb,
      uint256 minStts,
      uint256 minBnb,
      uint256 slippage
    )
  {
    (stts, bnb, ) = calculateLiquidityValue(users[user].liquidity);
    slippage = percent > 0 ? percent : MAX_SLIPPAGE;
    minStts = stts.mul(HUNDRED.sub(slippage)).div(HUNDRED);
    minBnb = bnb.mul(HUNDRED.sub(slippage)).div(HUNDRED);
  }

  // Pair Functions ----

  function freeze(
    address referrer,
    uint256 refPercent,
    uint256 sttsAmount,
    uint256 amountSTTSMin,
    uint256 amountBNBMin,
    uint256 deadline
  ) external payable override notLocked ensure(deadline) {
    address sender = _msgSender();
    require(users[sender].referrer == address(0), "Error::SmartPool02, User exist!");
    require(users[referrer].referrer != address(0), "Error::SmartPool02, Referrer not exist!");
    require(refPercent <= HUNDRED, "Error::SmartPool02, Incorrect referral percent!");
    require(
      IERC20(STTS).balanceOf(sender) >= sttsAmount,
      "Error::SmartPool02, Not enough STTS!"
    );

    uint256 bnbAmount = calculateBnb(sttsAmount);
    require(msg.value >= bnbAmount, "Error::SmartPool02, Not enough BNB!");

    _safeTransferFrom(STTS, sender, address(this), sttsAmount);

    (, uint256 amountETH, uint256 liquidity) =
      ROUTER.addLiquidityETH{value: bnbAmount}(
        STTS,
        sttsAmount,
        amountSTTSMin,
        amountBNBMin,
        address(this),
        deadline
      );

    require(liquidity >= MINIMUM_LP, "Error::SmartPool02, Small Amount of LPTOKEN!");

    users[sender].referrer = referrer;
    users[sender].liquidity = liquidity;
    users[sender].refPercent = refPercent;
    users[sender].latestWithdraw = block.timestamp;
    users[sender].deposit.push(Deposit(block.timestamp, calculateReward(sttsAmount)));

    if (msg.value > amountETH) _safeTransferBNB(sender, msg.value - amountETH);

    emit Freeze(sender, referrer, liquidity);
  }

  function updateFreeze(
    uint256 sttsAmount,
    uint256 amountSTTSMin,
    uint256 amountBNBMin,
    uint256 deadline
  ) external payable override notLocked ensure(deadline) {
    address sender = _msgSender();
    require(users[sender].referrer != address(0), "Error::SmartPool02, User not exist!");
    require(
      IERC20(STTS).balanceOf(sender) >= sttsAmount,
      "Error::SmartPool02, Not enough STTS!"
    );

    uint256 bnbAmount = calculateBnb(sttsAmount);
    require(msg.value >= bnbAmount, "Error::SmartPool02, Not enough BNB!");

    _safeTransferFrom(STTS, sender, address(this), sttsAmount);

    (, uint256 amountETH, uint256 liquidity) =
      ROUTER.addLiquidityETH{value: bnbAmount}(
        STTS,
        sttsAmount,
        amountSTTSMin,
        amountBNBMin,
        address(this),
        deadline
      );
    users[sender].liquidity = users[sender].liquidity.add(liquidity);
    users[sender].deposit.push(Deposit(block.timestamp, calculateReward(sttsAmount)));

    if (msg.value > amountETH) _safeTransferBNB(sender, msg.value - amountETH);

    emit UpdateFreeze(sender, liquidity);
  }

  function unfreeze(
    uint256 amountSTTSMin,
    uint256 amountBNBMin,
    uint256 deadline
  ) external override ensure(deadline) {
    address sender = _msgSender();
    uint256 liquidity = users[sender].liquidity;

    require(liquidity > 0, "Error::SmartPool02, User dosent have value!");

    require(withdrawInterest(), "Error::SmartPool02, Withdraw failed!");

    _safeApprove(LPTOKEN, address(ROUTER), liquidity);

    users[sender].liquidity = 0;
    delete users[sender].deposit;

    (uint256 amountToken, uint256 amountBNB) =
      ROUTER.removeLiquidityETH(
        STTS,
        liquidity,
        amountSTTSMin,
        amountBNBMin,
        sender,
        deadline
      );

    emit Unfreeze(sender, amountToken, amountBNB);
  }

  // End of Pair Functions ----

  // Liquidity Pool Token Functions --------

  function freezeLP(
    address referrer,
    uint256 refPercent,
    uint256 lpAmount
  ) external override notLocked {
    address sender = _msgSender();
    require(users[sender].referrer == address(0), "Error::SmartPool02, User exist!");
    require(users[referrer].referrer != address(0), "Error::SmartPool02, Referrer not exist!");
    require(refPercent <= HUNDRED, "Error::SmartPool02, Incorrect referral percent!");
    require(lpAmount >= MINIMUM_LP, "Error::SmartPool02, Small Amount of LPTOKEN!");
    require(
      IERC20(LPTOKEN).balanceOf(sender) >= lpAmount,
      "Error::SmartPool02, Not enough LPTOKEN!"
    );

    (uint256 sttsAmount, , ) = calculateLiquidityValue(lpAmount);

    _safeTransferFrom(LPTOKEN, sender, address(this), lpAmount);

    users[sender].referrer = referrer;
    users[sender].liquidity = lpAmount;
    users[sender].refPercent = refPercent;
    users[sender].latestWithdraw = block.timestamp;
    users[sender].deposit.push(Deposit(block.timestamp, calculateReward(sttsAmount)));

    emit FreezeLP(sender, referrer, lpAmount);
  }

  function updateFreezeLP(uint256 lpAmount) external override notLocked {
    address sender = _msgSender();
    require(users[sender].referrer != address(0), "Error::SmartPool02, User not exist!");
    require(lpAmount >= MINIMUM_LP, "Error::SmartPool02, Small Amount of LPTOKEN!");
    require(
      IERC20(LPTOKEN).balanceOf(sender) >= lpAmount,
      "Error::SmartPool02, Not enough LPTOKEN!"
    );

    (uint256 sttsAmount, , ) = calculateLiquidityValue(lpAmount);

    _safeTransferFrom(LPTOKEN, sender, address(this), lpAmount);

    users[sender].liquidity = users[sender].liquidity.add(lpAmount);
    users[sender].deposit.push(Deposit(block.timestamp, calculateReward(sttsAmount)));

    emit UpdateFreezeLP(sender, lpAmount);
  }

  function unfreezeLP() external override {
    address sender = _msgSender();
    uint256 liquidity = users[sender].liquidity;

    require(liquidity > 0, "Error::SmartPool02, User dosent have value!");

    require(withdrawInterest(), "Error::SmartPool02, Withdraw failed!");

    _safeApprove(LPTOKEN, address(ROUTER), liquidity);

    users[sender].liquidity = 0;
    delete users[sender].deposit;

    _safeTransfer(LPTOKEN, sender, liquidity);

    emit UnfreezeLP(sender, liquidity);
  }

  // End of Liquidity Pool token Function -------

  function withdrawInterest() public override notBlackListed returns (bool) {
    address sender = _msgSender();
    (uint256 daily, uint256 referrals, uint256 refValue, uint256 savedTime) =
      calculateInterest(sender);

    address referrer = users[sender].referrer;
    if (refValue > 0 && users[referrer].liquidity >= MINIMUM_LP) {
      users[referrer].refAmounts = users[referrer].refAmounts.add(refValue);
      emit ReferralReward(referrer, refValue);
    }

    uint256 reward = daily.add(referrals);

    if (reward > 0) {
      _safeTransfer(STTS, sender, reward);
      emit WithdrawInterest(sender, daily, referrals);
    }

    users[sender].latestWithdraw = savedTime;
    users[sender].refAmounts = 0;

    return true;
  }

  function calculateInterest(address user)
    public
    view
    override
    returns (
      uint256 daily,
      uint256 referral,
      uint256 referrer,
      uint256 requestTime
    )
  {
    require(users[user].referrer != address(0), "Error::SmartPool02, User not exist!");
    require(users[user].liquidity > 0, "Error::SmartPool02, User dosen't have value!");

    requestTime = block.timestamp;

    if (
      users[user].latestWithdraw < END_TIME &&
      users[user].latestWithdraw.add(1 days) <= requestTime
    ) daily = calculateDaily(user, requestTime);

    (referral, referrer) = calculateReferrals(user, daily);
  }

  function calculateReferrals(address sender, uint256 value)
    internal
    view
    returns (uint256 userValue, uint256 refValue)
  {
    (userValue, refValue) = calculatePercent(value, users[sender].refPercent);
    userValue = users[sender].refAmounts.add(userValue);
  }

  function calculateDaily(address sender, uint256 time)
    public
    view
    override
    returns (uint256 daily)
  {
    if (time > END_TIME) time = END_TIME;
    for (uint16 i; i < users[sender].deposit.length; i++) {
      uint256 startTime = users[sender].deposit[i].startTime;
      uint256 reward = users[sender].deposit[i].reward;
      uint256 latestWithdraw = users[sender].latestWithdraw;
      if (startTime > latestWithdraw) latestWithdraw = startTime;
      uint256 userDays = daysBetween(time, startTime);
      uint256 lastAmount = daysBetween(latestWithdraw, startTime).mul(reward);
      daily = daily.add(userDays.mul(reward).sub(lastAmount));
    }
  }

  function daysBetween(uint256 time1, uint256 time2) internal pure returns (uint256) {
    return time1.sub(time2).div(1 days);
  }

  function userDepositNumber(address user) external view override returns (uint256) {
    return users[user].deposit.length;
  }

  function userDepositDetails(address user, uint256 index)
    public
    view
    override
    returns (uint256 startTime, uint256 reward)
  {
    startTime = users[user].deposit[index].startTime;
    reward = users[user].deposit[index].reward;
  }

  receive() external payable {}
}
