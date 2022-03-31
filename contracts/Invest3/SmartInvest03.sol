// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ISmartInvest02.sol";
import "./ISmartInvest03.sol";
import "./ISmartWorld.sol";
import "./Secure.sol";

contract SmartInvest03 is ISmartInvest03, Secure {
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

  ISmartWorld internal STT = ISmartWorld(0xbBe476b50D857BF41bBd1EB02F777cb9084C1564);
  ISmartInvest02 internal Invest02 =
    ISmartInvest02(0xC31D7B8ddba18b4773e41913E60C5f01029f7c0B);

  address public STTS;
  address public BTCB;

  uint256 private MINIMUM_PERCENT = 1000;
  uint256 private REWARDS_PERCENT = 5000;
  uint256 private MAXIMUM_PERCENT = 14000;
  uint256 private HUNDRED_PERCENT = 100000;
  uint256 private MINIMUM_AMOUNTS = 10000000000;
  uint256 private REFERRAL_PERIOD = 10285 hours;

  mapping(address => UserStruct) public users;

  modifier newUser(address referrer) {
    require(!blacklist[_msgSender()], "Error::SmartInvest02, User blacklisted!");
    require(
      users[referrer].referrer != address(0),
      "Error::SmartInvest02, Referrer does not exist!"
    );
    require(users[_msgSender()].referrer == address(0), "Error::SmartInvest02, User exist!");
    _;
  }

  modifier oldUser() {
    require(!blacklist[_msgSender()], "Error::SmartInvest02, User blacklisted!");
    require(
      users[_msgSender()].referrer != address(0),
      "Error::SmartInvest02, User not exist!"
    );
    _;
  }

  constructor() {
    STTS = STT.STTS();
    BTCB = STT.BTCB();
    owner = _msgSender();
  }

  function totalReward(uint256 value) public pure override returns (uint256) {
    return value.mul(2);
  }

  function calcPercent(uint256 value) internal view returns (uint256) {
    return value.mul(MINIMUM_PERCENT).div(MINIMUM_AMOUNTS);
  }

  function maxPercent() public view override returns (uint256) {
    return MAXIMUM_PERCENT;
  }

  function rewardPercent(uint256 value) public view override returns (uint256) {
    if (value < MINIMUM_AMOUNTS) return value.mul(REWARDS_PERCENT).div(MINIMUM_AMOUNTS);
    uint256 percent = REWARDS_PERCENT.add(calcPercent(value.sub(MINIMUM_AMOUNTS)));
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
    return ref.mul(PERCENT).div(100);
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

  function btcPrice() public view override returns (uint256) {
    return Invest02.btcPrice();
  }

  function sttsToUSD(uint256 value) public view override returns (uint256) {
    return btcPrice().mul(STT.sttsToSatoshi(value)).div(10**8);
  }

  function bnbToUSD(uint256 value) public view override returns (uint256) {
    return btcPrice().mul(STT.bnbToSatoshi(value)).div(10**8);
  }

  function btcToUSD(uint256 value) public view override returns (uint256) {
    return btcPrice().mul(STT.btcToSatoshi(value)).div(10**8);
  }

  function sttsToUSDPrice() public view override returns (uint256) {
    return sttsToUSD(10**8);
  }

  function USDToStts(uint256 value) public view override returns (uint256) {
    return value.mul(10**8).div(sttsToUSDPrice());
  }

  function migrateByAdmin(address user) public override onlyOwner returns (bool) {
    require(users[user].referrer == address(0), "Error::SmartInvest02, User exist!");
    return migration(user);
  }

  function migrateByUser() public override returns (bool) {
    require(users[_msgSender()].referrer == address(0), "Error::SmartInvest02, User exist!");
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
    ) = Invest02.users(user);

    uint256 depositNumber = Invest02.userDepositNumber(user);

    for (uint256 i = 0; i < depositNumber; i++) {
      (uint256 period, uint256 reward, uint256 endTime) = Invest02.userDepositDetails(user, i);
      users[user].invest.push(Invest(period, reward, endTime.sub(period.mul(1 hours))));
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

  function investStts(address referrer, uint256 value)
    public
    override
    newUser(referrer)
    returns (bool)
  {
    uint256 usd = sttsToUSD(value);
    require(usd >= MINIMUM_AMOUNTS, "Error::SmartInvest02, Incorrect Value!");
    require(
      STT.depositToken(STTS, _msgSender(), value),
      "Error::SmartInvest02, Deposit failed!"
    );
    return depositUser(referrer, usd, true);
  }

  function investBnb(address referrer)
    public
    payable
    override
    newUser(referrer)
    returns (bool)
  {
    uint256 usd = bnbToUSD(msg.value);
    require(usd >= MINIMUM_AMOUNTS, "Error::SmartInvest02, Incorrect Value!");
    require(
      STT.deposit{value: msg.value}(_msgSender(), msg.value),
      "Error::SmartInvest02, Deposit failed!"
    );
    return depositUser(referrer, usd, false);
  }

  function investBtcb(address referrer, uint256 value)
    public
    override
    newUser(referrer)
    returns (bool)
  {
    uint256 usd = btcToUSD(value);
    require(usd >= MINIMUM_AMOUNTS, "Error::SmartInvest02, Incorrect Value!");
    require(
      STT.depositToken(BTCB, _msgSender(), value),
      "Error::SmartInvest02, Deposit failed!"
    );
    return depositUser(referrer, usd, false);
  }

  function updateStts(uint256 value) public override oldUser returns (bool) {
    uint256 usd = sttsToUSD(value);
    require(usd >= MINIMUM_AMOUNTS, "Error::SmartInvest02, Incorrect Value!");
    require(
      STT.depositToken(STTS, _msgSender(), value),
      "Error::SmartInvest02, Deposit failed!"
    );
    return
      userExpired(_msgSender()) ? refreshUser(usd, true) : depositUser(address(0), usd, true);
  }

  function updateBnb() public payable override oldUser returns (bool) {
    uint256 usd = bnbToUSD(msg.value);
    require(usd >= MINIMUM_AMOUNTS, "Error::SmartInvest02, Incorrect Value!");
    require(
      STT.deposit{value: msg.value}(_msgSender(), msg.value),
      "Error::SmartInvest02, Deposit failed!"
    );
    return
      userExpired(_msgSender())
        ? refreshUser(usd, false)
        : depositUser(address(0), usd, false);
  }

  function updateBtcb(uint256 value) public override oldUser returns (bool) {
    uint256 usd = btcToUSD(value);
    require(usd >= MINIMUM_AMOUNTS, "Error::SmartInvest02, Incorrect Value!");
    require(
      STT.depositToken(BTCB, _msgSender(), value),
      "Error::SmartInvest02, Deposit failed!"
    );
    return
      userExpired(_msgSender())
        ? refreshUser(usd, false)
        : depositUser(address(0), usd, false);
  }

  function depositUser(
    address referrer,
    uint256 value,
    bool withStts
  ) internal returns (bool) {
    uint256 refValue = withStts ? value : value.mul(75).div(100);
    (uint256 period, uint256 reward, uint256 startTime) = rewardInfo(refValue);
    (uint256 totalAmount, uint256 refPercent) = referralInfo(_msgSender(), refValue);
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

  function refreshUser(uint256 value, bool withStts) internal returns (bool) {
    uint256 refValue = withStts ? value : value.mul(75).div(100);
    (uint256 period, uint256 reward, uint256 startTime) = rewardInfo(refValue);
    users[_msgSender()].invest.push(Invest(period, reward, startTime));
    users[_msgSender()].totalAmount = refValue;
    users[_msgSender()].refPercent = referralPercent(refValue);
    users[_msgSender()].refEndTime = block.timestamp.add(REFERRAL_PERIOD);
    payReferrer(_msgSender(), value);
    emit RefreshUser(_msgSender(), value);
    return true;
  }

  function payReferrer(address lastRef, uint256 value) private {
    for (uint256 i = 0; i < LEVEL; i++) {
      address refParent = users[lastRef].referrer;
      if (refParent == address(0)) break;
      if (!userExpired(refParent)) {
        uint256 userReward = value.mul(users[refParent].refPercent).div(HUNDRED_PERCENT);
        users[refParent].refAmounts = users[refParent].refAmounts.add(userReward);
      }
      lastRef = refParent;
    }
  }

  function withdrawInterest() public override notBlackListed returns (bool) {
    (uint256 hourly, uint256 referrals, uint256 savedTime) = calculateInterest(_msgSender());

    uint256 sttsAmount = USDToStts(hourly.add(referrals));

    _safeTransfer(STTS, _msgSender(), sttsAmount);

    users[_msgSender()].refAmounts = 0;
    users[_msgSender()].latestWithdraw = savedTime;

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
    require(users[user].referrer != address(0), "Error::SmartInvest02, User not exist!");
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
    for (uint16 i; i < users[sender].invest.length; i++) {
      uint256 period = users[sender].invest[i].period;
      uint256 reward = users[sender].invest[i].reward;
      uint256 startTime = users[sender].invest[i].startTime;
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
}
