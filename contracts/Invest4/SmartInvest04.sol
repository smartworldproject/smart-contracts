// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ISmartInvest04.sol";
import "./ISmartInvest03.sol";
import "./Secure.sol";

contract SmartInvest04 is ISmartInvest04, Secure {
  using SafeMath for uint256;

  struct Invest {
    uint256 period;
    uint256 reward;
    uint256 startTime;
  }

  struct UserStruct {
    Invest[] invest;
    address referrer;
    uint256 refEndTime;
    uint256 refAmounts;
    uint256 refPercent;
    uint256 totalAmount;
    uint256 latestWithdraw;
  }

  ISmartInvest03 internal Invest03 =
    ISmartInvest03(0x9fB8C5a61a9e6C7aFa42c692F79C6a0DCC7BdA75);

  uint256 private constant MINIMUM_PERCENT = 1000;
  uint256 private constant MAXIMUM_PERCENT = 14000;
  uint256 private constant HUNDRED_PERCENT = 100000;
  uint256 private constant HUNDRED_DOLLARS = 10000000000;
  uint256 private constant REFERRAL_PERIOD = 10285 hours;

  mapping(address => UserStruct) public override users;

  constructor(address[] memory blackAddresses) {
    owner = _msgSender();
    migrateByUser();

    for (uint256 i = 0; i < blackAddresses.length; i++) {
      address addr = blackAddresses[i];
      blacklist[addr] = true;
    }
  }

  function maxPercent() public pure override returns (uint256) {
    return MAXIMUM_PERCENT;
  }

  function totalReward(uint256 value) public pure override returns (uint256) {
    return value.mul(2);
  }

  function calcPercent(uint256 value) internal pure returns (uint256) {
    return value.mul(MINIMUM_PERCENT).div(HUNDRED_DOLLARS);
  }

  function rewardPercent(uint256 value) public view override returns (uint256) {
    if (value <= HUNDRED_DOLLARS) return BASE_REWARD_PERCENT;
    uint256 percent = BASE_REWARD_PERCENT.add(calcPercent(value.sub(HUNDRED_DOLLARS)));
    return percent > MAXIMUM_PERCENT ? MAXIMUM_PERCENT : percent;
  }

  function monthlyReward(uint256 value) public view override returns (uint256) {
    return value.mul(rewardPercent(value)).div(HUNDRED_PERCENT);
  }

  function hourlyReward(uint256 value) public view override returns (uint256) {
    return monthlyReward(value).div(MONTH);
  }

  function rewardPeriod(uint256 value) public view override returns (uint256) {
    return totalReward(value).div(hourlyReward(value));
  }

  function bnbToUSD(uint256 value) public view override returns (uint256) {
    return Invest03.bnbToUSD(value);
  }

  function bnbPrice() public view override returns (uint256) {
    return bnbToUSD(10**18);
  }

  function USDToBnb(uint256 value) public view override returns (uint256) {
    return value.mul(10**18).div(bnbPrice());
  }

  function rewardInfo(uint256 value)
    public
    view
    override
    returns (
      uint256 period,
      uint256 reward,
      uint256 startTime
    )
  {
    period = rewardPeriod(value);
    reward = hourlyReward(value);
    startTime = block.timestamp;
  }

  function referralPercent(uint256 value) public view returns (uint256) {
    uint256 ref = value < 100000000000 ? value / 100000000 : value < 2100000000000
      ? 1000 + (value - 100000000000) / 2000000000
      : value < 6100000000000
      ? 2000 + (value - 2100000000000) / 4000000000
      : value < 14100000000000
      ? 3000 + (value - 6100000000000) / 8000000000
      : 4000;
    return ref.mul(REFERRAL_PERCENT).div(100);
  }

  function referralInfo(address user, uint256 value)
    public
    view
    override
    returns (uint256 totalAmount, uint256 refPercent)
  {
    totalAmount = users[user].totalAmount.add(value);
    refPercent = referralPercent(totalAmount);
  }

  function hoursBetween(uint256 time1, uint256 time2) internal pure returns (uint256) {
    return time1.sub(time2).div(1 hours);
  }

  function migrateByAdmin(address user) public override onlyOwner returns (bool) {
    require(users[user].referrer == address(0), "Error::SmartInvest03, User exist!");
    return migration(user);
  }

  function migrateByUser() public override returns (bool) {
    require(users[_msgSender()].referrer == address(0), "Error::SmartInvest03, User exist!");
    return migration(_msgSender());
  }

  function migration(address user) internal returns (bool) {
    (
      address referrer,
      uint256 refEndTime,
      uint256 refAmounts,
      uint256 refPercent,
      uint256 totalAmount,
      uint256 latestWithdraw
    ) = Invest03.users(user);

    uint256 depositNumber = Invest03.userDepositNumber(user);

    for (uint256 i = 0; i < depositNumber; i++) {
      (, uint256 period, uint256 reward, uint256 startTime, ) = Invest03.userDepositDetails(
        user,
        i
      );
      users[user].invest.push(Invest(period, reward, startTime));
    }

    users[user].referrer = referrer;
    users[user].refEndTime = refEndTime;
    users[user].refAmounts = refAmounts;
    users[user].refPercent = refPercent;
    users[user].totalAmount = totalAmount;
    users[user].latestWithdraw = latestWithdraw;

    emit Migration(user, referrer, totalAmount);
    return true;
  }

  function invest(address referrer) public payable override notBlackListed returns (bool) {
    uint256 fee = msg.value.mul(FEE).div(HUNDRED_PERCENT);
    uint256 usd = bnbToUSD(msg.value.sub(fee));
    require(usd >= MINIMUM_INVEST, "Error::SmartInvest03, Incorrect Value!");

    bool notExist = users[_msgSender()].referrer == address(0);

    if (notExist) {
      uint256 depositNumber = Invest03.userDepositNumber(_msgSender());
      if (depositNumber > 0) {
        require(migration(_msgSender()), "Error::SmartInvest03, Migration Failed!");
        return userExpired(_msgSender()) ? refreshUser(usd) : depositUser(address(0), usd);
      }
      require(
        users[referrer].referrer != address(0),
        "Error::SmartInvest03, Referrer does not exist!"
      );
      return depositUser(referrer, usd);
    }
    return userExpired(_msgSender()) ? refreshUser(usd) : depositUser(address(0), usd);
  }

  function depositUser(address referrer, uint256 value) internal returns (bool) {
    (uint256 period, uint256 reward, uint256 startTime) = rewardInfo(value);
    (uint256 totalAmount, uint256 refPercent) = referralInfo(_msgSender(), value);
    users[_msgSender()].invest.push(Invest(period, reward, startTime));
    users[_msgSender()].totalAmount = totalAmount;
    users[_msgSender()].refPercent = refPercent;
    if (referrer != address(0)) {
      users[_msgSender()].referrer = referrer;
      users[_msgSender()].latestWithdraw = block.timestamp;
      users[_msgSender()].refEndTime = block.timestamp.add(REFERRAL_PERIOD);
      payReferrer(_msgSender(), value);
      emit RegisterUser(_msgSender(), referrer, value);
    } else {
      payReferrer(_msgSender(), value);
      emit UpdateUser(_msgSender(), value);
    }
    return true;
  }

  function refreshUser(uint256 value) internal returns (bool) {
    (uint256 period, uint256 reward, uint256 startTime) = rewardInfo(value);
    users[_msgSender()].invest.push(Invest(period, reward, startTime));
    users[_msgSender()].totalAmount = value;
    users[_msgSender()].refPercent = referralPercent(value);
    users[_msgSender()].refEndTime = block.timestamp.add(REFERRAL_PERIOD);
    payReferrer(_msgSender(), value);
    emit RefreshUser(_msgSender(), value);
    return true;
  }

  function payReferrer(address lastRef, uint256 value) private {
    for (uint256 i = 0; i < REFERRAL_LEVEL; i++) {
      address refParent = users[lastRef].referrer;
      if (refParent == address(0)) break;
      if (!userExpired(refParent)) {
        uint256 userReward = value.mul(users[refParent].refPercent).div(HUNDRED_PERCENT);
        users[refParent].refAmounts = users[refParent].refAmounts.add(userReward);
      }
      lastRef = refParent;
    }
  }

  function migrateAndWithdrawInterest() public override notBlackListed returns (bool) {
    require(migrateByUser(), "Error::SmartInvest03, Migration Failed!");
    return withdrawInterest();
  }

  function withdrawInterest() public override notBlackListed returns (bool) {
    (uint256 hourly, uint256 referrals, uint256 savedTime) = calculateInterest(_msgSender());

    uint256 bnbAmount = USDToBnb(hourly.add(referrals));

    users[_msgSender()].refAmounts = 0;
    users[_msgSender()].latestWithdraw = savedTime;

    _safeTransferBNB(_msgSender(), bnbAmount);

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
    require(users[user].referrer != address(0), "Error::SmartInvest03, User not exist!");
    requestTime = block.timestamp;

    referral = users[user].refAmounts;

    if (users[user].latestWithdraw.add(1 hours) <= requestTime)
      hourly = calculateHourly(user, requestTime);

    return (hourly, referral, requestTime);
  }

  function calculateHourly(address sender, uint256 time)
    public
    view
    override
    returns (uint256 hourly)
  {
    Invest[] storage userIvest = users[sender].invest;
    for (uint16 i; i < userIvest.length; i++) {
      uint256 period = userIvest[i].period;
      uint256 reward = userIvest[i].reward;
      uint256 startTime = userIvest[i].startTime;
      uint256 endTime = startTime.add(period.mul(1 hours));
      uint256 latestWithdraw = users[sender].latestWithdraw;
      if (latestWithdraw < endTime) {
        if (startTime > latestWithdraw) latestWithdraw = startTime;
        uint256 lastAmount = 0;
        uint256 userHours = hoursBetween(time, startTime);
        if (userHours > period) userHours = period;
        if (latestWithdraw > startTime.add(1 hours))
          lastAmount = hoursBetween(latestWithdraw, startTime).mul(reward);
        hourly = hourly.add(userHours.mul(reward).sub(lastAmount));
      }
    }
  }

  function userDepositNumber(address user) public view override returns (uint256) {
    return users[user].invest.length;
  }

  function userDepositDetails(address user, uint256 index)
    public
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
    period = users[user].invest[index].period;
    reward = users[user].invest[index].reward;
    amount = reward.mul(period).div(2);
    startTime = users[user].invest[index].startTime;
    endTime = startTime.add(period.mul(1 hours));
  }

  function userExpired(address user) public view override returns (bool) {
    return users[user].refEndTime >= block.timestamp ? false : true;
  }

  receive() external payable {}
}
