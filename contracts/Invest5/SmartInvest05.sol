// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ISmartInvest05.sol";
import "./SmartSecure.sol";
import "./Aggregator.sol";
import "./SmartMath.sol";

contract SmartInvest05 is ISmartInvest05, SmartSecure {
  using SmartMath for uint256;

  struct Invest {
    uint128 reward;
    uint128 startTime;
  }

  struct UserStruct {
    Invest[] invest;
    address referrer;
    uint256 refAmounts;
    uint256 totalAmount;
    uint256 latestWithdraw;
  }

  Aggregator private constant priceFeed =
    Aggregator(0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7);

  uint64 private constant MINIMUM_PERCENT = 1000;
  uint64 private constant HUNDRED_PERCENT = 100000;
  uint64 private constant REWARD_PERIOD_HOURS = 28800;
  uint64 private constant REWARD_PERIOD_SECOND = 28800 hours;

  address[] public override userList;
  mapping(address => UserStruct) public override users;

  constructor() {
    owner = _msgSender();
    _deposit(address(priceFeed), MAXIMUM_INVEST);
  }

  receive() external payable {
    invest(owner);
  }

  // Price Calculation
  function BNBPrice() public view override returns (uint256) {
    (, int256 price, , , ) = priceFeed.latestRoundData();
    return uint256(price);
  }

  function USDtoBNB(uint256 value) public view override returns (uint256) {
    return value.mulDecimals(18).div(BNBPrice());
  }

  function BNBtoUSD(uint256 value) public view override returns (uint256) {
    return value.mul(BNBPrice()).divDecimals(18);
  }

  function BNBtoUSDWithFee(uint256 value) public view override returns (uint256) {
    uint256 fee = value.mul(FEE).div(HUNDRED_PERCENT);
    return BNBtoUSD(value.sub(fee));
  }

  // Investment Informtaion
  function monthlyReward(uint256 value) public view override returns (uint256) {
    return value.mul(MONTHLY_REWARD_PERCENT).div(HUNDRED_PERCENT);
  }

  function hourlyReward(uint256 value) public view override returns (uint256) {
    return monthlyReward(value).div(720);
  }

  function refMultiplier(address user, uint8 level) public view override returns (uint256) {
    uint256 totalInvest = users[user].totalAmount;
    if (totalInvest < MINIMUM_INVEST) return 0;
    uint256 percent = level == 0 ? 10000 : level < 5 ? 2000 : 1000;
    return totalInvest < MAXIMUM_INVEST ? percent.div(2) : percent;
  }

  // Investment Deposit
  function invest(address referrer) public payable override returns (bool) {
    uint256 value = BNBtoUSDWithFee(msg.value);
    require(value >= MINIMUM_INVEST, "VAL");
    if (users[_msgSender()].referrer == address(0)) {
      require(users[referrer].referrer != address(0), "REF");
      return _deposit(referrer, value);
    }
    return _deposit(address(0), value);
  }

  function _deposit(address referrer, uint256 value) private returns (bool) {
    users[_msgSender()].invest.push(
      Invest((hourlyReward(value).toUint128()), block.timestamp.toUint128())
    );
    users[_msgSender()].totalAmount = users[_msgSender()].totalAmount.add(value);
    if (referrer != address(0)) {
      users[_msgSender()].referrer = referrer;
      users[_msgSender()].latestWithdraw = block.timestamp;
      _payReferrer(_msgSender(), value);
      userList.push(_msgSender());
      emit RegisterUser(_msgSender(), referrer, value);
    } else {
      _payReferrer(_msgSender(), value);
      emit UpdateUser(_msgSender(), value);
    }
    return true;
  }

  function _payReferrer(address lastRef, uint256 value) private {
    for (uint8 i = 0; i < REFERRAL_LEVEL; i++) {
      address refParent = users[lastRef].referrer;
      if (refParent == address(0)) break;
      uint256 multiplier = refMultiplier(refParent, i);
      if (multiplier > 0) {
        uint256 userReward = value.mul(multiplier).div(REFERRAL_PERCENT);
        users[refParent].refAmounts = users[refParent].refAmounts.add(userReward);
      }
      lastRef = refParent;
    }
  }

  // Widthraw Funtions
  function withdrawInterest() external override secured returns (bool) {
    require(users[_msgSender()].referrer != address(0), "USR");
    (uint256 hourly, uint256 referrals, uint256 savedTime) = calculateInterest(_msgSender());

    uint256 bnbAmount = USDtoBNB(hourly.add(referrals));

    users[_msgSender()].refAmounts = 0;
    users[_msgSender()].latestWithdraw = savedTime;

    _safeTransferETH(_msgSender(), bnbAmount);

    emit WithdrawInterest(_msgSender(), hourly, referrals);
    return true;
  }

  function calculateInterest(address user)
    public
    view
    override
    returns (
      uint256 hourly,
      uint256 referral,
      uint256 requestTime
    )
  {
    referral = users[user].refAmounts;
    requestTime = block.timestamp;

    if (users[user].latestWithdraw.addHour() <= requestTime)
      (hourly, ) = calculateHourly(user, requestTime);

    return (hourly, referral, requestTime);
  }

  function calculateHourly(address sender, uint256 time)
    public
    view
    override
    returns (uint256 current, uint256 past)
  {
    Invest[] storage userIvest = users[sender].invest;
    for (uint8 i = 0; i < userIvest.length; i++) {
      uint256 reward = userIvest[i].reward;
      uint256 startTime = userIvest[i].startTime;
      uint256 latestWithdraw = users[sender].latestWithdraw;
      if (latestWithdraw < startTime.add(REWARD_PERIOD_SECOND)) {
        if (startTime > latestWithdraw) latestWithdraw = startTime;
        uint256 currentHours = time.sub(startTime).toHours();
        if (currentHours > REWARD_PERIOD_HOURS) currentHours = REWARD_PERIOD_HOURS;
        if (latestWithdraw > startTime.addHour()) {
          uint256 pastHours = latestWithdraw.sub(startTime).toHours();
          past = past.add(pastHours.mul(reward));
        }
        current = current.add(currentHours.mul(reward));
      }
    }
    current = current.sub(past);
  }

  // User API
  function userListLength() external view override returns (uint256) {
    return userList.length;
  }

  function userDepositNumber(address user) external view override returns (uint256) {
    return users[user].invest.length;
  }

  function userDepositDetails(address user, uint256 index)
    external
    view
    override
    returns (
      uint256 amount,
      uint256 reward,
      uint256 startTime,
      uint256 endTime
    )
  {
    reward = users[user].invest[index].reward;
    amount = reward.mul(REWARD_PERIOD_HOURS).div(2);
    startTime = users[user].invest[index].startTime;
    endTime = startTime.add(REWARD_PERIOD_SECOND);
  }
}
