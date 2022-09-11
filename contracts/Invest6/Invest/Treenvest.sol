// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Math.sol";
import "./Secure.sol";
import "./ITreenvest.sol";
import "./Aggregator.sol";
import "../Plan/IPlan.sol";

contract Treenvest is ITreenvest, Secure {
  using Math for uint256;
  using Math for uint64;

  Aggregator private PriceFeed;
  IUserData private UserData;
  IPlan private Plan;

  constructor(
    address priceFeed,
    address userData,
    address plan
  ) {
    PriceFeed = Aggregator(priceFeed);
    UserData = IUserData(userData);
    Plan = IPlan(plan);
  }

  modifier nonReentrant() {
    require(UserData.notBlacklisted(_msgSender()), "TREE::BLK");
    require(!locked, "TREE::LCK");
    locked = true;
    _;
    locked = false;
  }

  receive() external payable {
    investFree();
  }

  // Investment functions
  function investFree() public payable override {
    uint64 usdValue = validateToUSD(msg.value);

    _depositFree(usdValue);
    emit InvestFree(_msgSender(), usdValue);
  }

  function invest3Month(address referrer, uint256 gift)
    external
    payable
    override
  {
    uint64 usdValue = validateToUSD(msg.value);

    _deposit(referrer, usdValue, gift, false);
    emit Invest3Month(_msgSender(), referrer, usdValue);
  }

  function invest6Month(address referrer, uint256 gift)
    external
    payable
    override
  {
    uint64 usdValue = validateToUSD(msg.value);

    _deposit(referrer, usdValue, gift, true);
    emit Invest6Month(_msgSender(), referrer, usdValue);
  }

  function upgradeToMonthly(
    uint256 index,
    uint256 gift,
    bool six
  ) external override {
    (
      uint256 amount,
      uint256 period,
      uint256 reward,
      uint256 startTime,
      uint256 endTime
    ) = UserData.depositDetail(_msgSender(), index);

    require(period == 0 && reward > 0, "TREE::NUP");
    require(endTime <= block.timestamp, "TREE::NEX");

    IUserData.Invest memory invest;
    invest.amount = amount.toUint64();
    invest.period = Plan.calcPeriod(six).toUint64();
    invest.reward = Plan.hourlyReward(amount).toUint64();
    invest.startTime = startTime.toUint64();

    require(
      UserData.changeInvestIndex(_msgSender(), index, invest),
      "TREE::INF"
    );

    if (!UserData.exist(_msgSender())) {
      UserData.register(_msgSender(), owner(), gift);
    }
    emit UpgradeToMonthly(_msgSender(), amount);
  }

  // Widthraw Funtions
  function withdrawInterest() public override nonReentrant {
    (uint256 hourly, uint256 referral, uint256 gift, ) = calculateInterest(
      _msgSender()
    );
    uint256 totalUsdReward = hourly.add(referral).add(gift);

    require(UserData.resetAfterWithdraw(_msgSender()), "TREE::WFA");

    if (totalUsdReward > 0) {
      _safeTransferETH(_msgSender(), USDtoBNB(totalUsdReward));
    }
    emit WithdrawInterest(_msgSender(), hourly, referral, gift);
  }

  // zero gift = free invest but without bonus reward
  function withdrawToInvest(uint256 gift, bool six)
    external
    override
    nonReentrant
  {
    (uint256 _hourly, uint256 _referrals, uint256 _gift, ) = calculateInterest(
      _msgSender()
    );
    uint256 totalUsdReward = _hourly.add(_referrals).add(_gift);

    require(Plan.valueIsEnough(totalUsdReward), "TREE::VAL");
    require(UserData.resetAfterWithdraw(_msgSender()), "TREE::WFA");

    if (gift > 0) {
      uint256 value = Plan.valuePlusBonus(totalUsdReward, six);
      _deposit(owner(), value.toUint64(), gift, six);
    } else {
      _depositFree(totalUsdReward.toUint64());
    }
    emit WithdrawToInvest(_msgSender(), _hourly, _referrals, _gift);
  }

  function withdrawInvest(uint256 index) external override {
    (uint256 amount, , , , uint256 endTime) = UserData.depositDetail(
      _msgSender(),
      index
    );

    require(endTime <= block.timestamp, "TREE::NEX");

    withdrawInterest();

    require(
      UserData.changeInvestIndexReward(_msgSender(), index, 0),
      "TREE::WFA"
    );

    _safeTransferETH(_msgSender(), USDtoBNB(amount));

    emit WithdrawInvest(_msgSender(), amount);
  }

  // Private Functions
  function _depositFree(uint64 _usdValue) private {
    IUserData.Invest memory invest;
    invest.amount = _usdValue;
    invest.period = 0;
    invest.reward = Plan.freeHourlyReward(_usdValue).toUint64();
    invest.startTime = block.timestamp.toUint64();

    require(UserData.investment(_msgSender(), invest), "TREE::INF");
  }

  function _deposit(
    address _referrer,
    uint64 _usdValue,
    uint256 _gift,
    bool _six
  ) private {
    IUserData.Invest memory invest;
    invest.amount = _usdValue;
    invest.period = Plan.calcPeriod(_six).toUint64();
    invest.reward = Plan.hourlyReward(_usdValue).toUint64();
    invest.startTime = block.timestamp.toUint64();

    require(UserData.investment(_msgSender(), invest), "TREE::INF");

    if (!UserData.exist(_msgSender())) {
      UserData.register(_msgSender(), _referrer, _gift);
    }
    address referrer = UserData.referrer(_msgSender());
    if (referrer != address(0)) {
      uint256 refValue = Plan.calcRefValue(
        _usdValue,
        UserData.maxPeriod(referrer)
      );
      UserData.addRefAmount(referrer, refValue);
    }
  }

  // interest calculater
  function calculateInterest(address user)
    public
    view
    override
    returns (
      uint256 hourly,
      uint256 referral,
      uint256 gift,
      uint256 requestTime
    )
  {
    uint256 latestWithdraw;
    (, referral, gift, latestWithdraw) = UserData.users(user);

    requestTime = block.timestamp;

    if (latestWithdraw.addHour() <= requestTime) {
      hourly = UserData.calculateHourly(user, requestTime);
    }
    return (hourly, referral, gift, requestTime);
  }

  // Price Calculation
  function BNBPrice() public view override returns (uint256) {
    (, int256 price, , , ) = PriceFeed.latestRoundData();
    return uint256(price);
  }

  function USDtoBNB(uint256 value) public view override returns (uint256) {
    return value.mulDecimals(18).div(BNBPrice());
  }

  function BNBtoUSD(uint256 value) public view override returns (uint256) {
    return value.mul(BNBPrice()).divDecimals(18);
  }

  function validateToUSD(uint256 value) internal view returns (uint64) {
    uint256 usdValue = BNBtoUSD(Plan.valueMinusFee(value));
    require(Plan.valueIsEnough(usdValue), "TREE::VAL");
    return usdValue.toUint64();
  }

  // User API
  function BNBValue(address user) external view override returns (uint256) {
    return user.balance;
  }

  function users(address user)
    external
    view
    override
    returns (
      address referrer,
      uint256 refAmount,
      uint256 giftAmount,
      uint256 latestWithdraw
    )
  {
    return UserData.users(user);
  }

  function userDepositNumber(address user)
    external
    view
    override
    returns (uint256)
  {
    return UserData.depositNumber(user);
  }

  function userInvestDetails(address user)
    external
    view
    override
    returns (IUserData.Invest[] memory)
  {
    return UserData.investDetails(user);
  }

  function userDepositDetails(address user, uint256 index)
    external
    view
    override
    returns (
      uint256 amount,
      uint256 period,
      uint256 reward,
      uint256 startTime,
      uint256 endTime
    )
  {
    return UserData.depositDetail(user, index);
  }

  function userInvestExpired(address user, uint256 index)
    external
    view
    override
    returns (bool)
  {
    return UserData.investIsExpired(user, index);
  }

  function userMaxMonth(address user) external view override returns (uint256) {
    return UserData.maxPeriod(user).div(30 days);
  }
}
