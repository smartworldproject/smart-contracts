// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./ISmartInvest.sol";
import "./ISmartWorld.sol";

contract SmartInvest is ISmartInvest, Context {
  using SafeMath for uint256;

  struct Invest {
    uint256 reward;
    uint256 endTime;
  }

  struct UserStruct {
    uint256 id;
    uint256 refID;
    uint256 refAmounts;
    uint256 refPercent;
    uint256 latestWithdraw;
    Invest[] invest;
  }

  ISmartWorld internal STT;

  address public STTS;
  address public BTCB;
  uint256 private PERIOD_HOURS = 17520;
  uint256 private PERIOD_TIMES = 17520 hours;
  uint256 private MINIMUM_INVEST = 500000;
  uint256 private MAXIMUM_INVEST = 5000000;

  uint256 public userID = 1;
  mapping(address => UserStruct) public users;
  mapping(uint256 => address) private userList;

  constructor(address stt) {
    STT = ISmartWorld(stt);
    STTS = STT.STTS();
    BTCB = STT.BTCB();
    users[_msgSender()].id = userID;
    users[_msgSender()].refID = 0;
    users[_msgSender()].latestWithdraw = block.timestamp.sub(1 hours);
    users[_msgSender()].invest.push(Invest(0, block.timestamp));
    userList[userID] = _msgSender();
  }

  function totalReward(uint256 value) public view override returns (uint256) {
    return value.div(5).mul(2).div(STT.sttPrice()).mul(10**8);
  }

  function hourlyReward(uint256 value) public view override returns (uint256) {
    return totalReward(value).div(PERIOD_HOURS);
  }

  function hoursBetween(uint256 time1, uint256 time2) internal pure returns (uint256) {
    return time1.sub(time2).div(1 hours);
  }

  function maxPercent() public view override returns (uint256) {
    uint256 controller = STT.totalSupply().div(10**16).mul(100);
    uint256 max = 1000 - controller;
    return max < 100 ? 100 : max;
  }

  function calculatePercent(address user, uint256 value)
    public
    view
    override
    returns (uint256)
  {
    uint256 userPer = users[user].refPercent;
    uint256 maxPer = maxPercent();
    if (userExpired(user)) userPer = 0;
    if (userPer > maxPer) return userPer;
    uint256 percent = userPer.add(value.mul(maxPer).div(MAXIMUM_INVEST));
    return percent > maxPer ? maxPer : percent;
  }

  function investBnb(address referrer) public payable override returns (bool) {
    require(users[_msgSender()].id == 0, "Error::Investment, User exist!");
    require(users[referrer].id > 0, "Error::Investment, Referrer does not exist!");
    uint256 satoshi = STT.bnbToSatoshi(msg.value);
    require(satoshi >= MINIMUM_INVEST, "Error::Investment, Incorrect Value!");
    require(
      STT.deposit{value: msg.value}(_msgSender(), msg.value),
      "Error::Investment, Deposit failed!"
    );
    return registerUser(referrer, satoshi, false);
  }

  function investStts(address referrer, uint256 value) public override returns (bool) {
    require(users[_msgSender()].id == 0, "Error::Investment, User exist!");
    require(users[referrer].id > 0, "Error::Investment, Referrer does not exist!");
    uint256 satoshi = STT.sttsToSatoshi(value);
    require(satoshi >= MINIMUM_INVEST, "Error::Investment, Incorrect Value!");
    require(STT.depositToken(STTS, _msgSender(), value), "Error::Investment, Deposit failed!");
    return registerUser(referrer, satoshi, true);
  }

  function investBtcb(address referrer, uint256 value) public override returns (bool) {
    require(users[_msgSender()].id == 0, "Error::Investment, User exist!");
    require(users[referrer].id > 0, "Error::Investment, Referrer does not exist!");
    uint256 satoshi = STT.btcToSatoshi(value);
    require(satoshi >= MINIMUM_INVEST, "Error::Investment, Incorrect Value!");
    require(STT.depositToken(BTCB, _msgSender(), value), "Error::Investment, Deposit failed!");
    return registerUser(referrer, satoshi, false);
  }

  function registerUser(
    address referrer,
    uint256 value,
    bool withStts
  ) internal returns (bool) {
    uint256 refID = users[referrer].id;
    userID++;
    userList[userID] = _msgSender();
    users[_msgSender()].id = userID;
    users[_msgSender()].refID = refID;
    users[_msgSender()].invest.push(
      Invest(hourlyReward(value), block.timestamp.add(PERIOD_TIMES))
    );
    users[_msgSender()].latestWithdraw = block.timestamp.sub(1 hours);
    uint256 refValue = withStts ? value.mul(125).div(100) : value;
    users[_msgSender()].refPercent = calculatePercent(_msgSender(), refValue);
    payReferrer(users[_msgSender()].id, totalReward(value));
    emit RegisterUser(_msgSender(), userList[refID], value);
    return true;
  }

  function updateBnb() public payable override returns (bool) {
    require(users[_msgSender()].id > 0, "Error::Investment, User not exist!");
    uint256 satoshi = STT.bnbToSatoshi(msg.value);
    require(satoshi >= MINIMUM_INVEST, "Error::Investment, Incorrect Value!");
    require(
      STT.deposit{value: msg.value}(_msgSender(), msg.value),
      "Error::Investment, Deposit failed!"
    );
    return updateUser(satoshi, false);
  }

  function updateStts(uint256 value) public override returns (bool) {
    require(users[_msgSender()].id > 0, "Error::Investment, User not exist!");
    uint256 satoshi = STT.sttsToSatoshi(value);
    require(satoshi >= MINIMUM_INVEST, "Error::Investment, Incorrect Value!");
    require(STT.depositToken(STTS, _msgSender(), value), "Error::Investment, Deposit failed!");
    return updateUser(satoshi, true);
  }

  function updateBtcb(uint256 value) public override returns (bool) {
    require(users[_msgSender()].id > 0, "Error::Investment, User not exist!");
    uint256 satoshi = STT.btcToSatoshi(value);
    require(satoshi >= MINIMUM_INVEST, "Error::Investment, Incorrect Value!");
    require(STT.depositToken(BTCB, _msgSender(), value), "Error::Investment, Deposit failed!");
    return updateUser(satoshi, false);
  }

  function updateUser(uint256 value, bool withStts) private returns (bool) {
    uint256 refValue = withStts ? value.mul(125).div(100) : value;
    users[_msgSender()].refPercent = calculatePercent(_msgSender(), refValue);

    if (userExpired(_msgSender())) {
      users[_msgSender()].invest.push(users[_msgSender()].invest[0]);
      users[_msgSender()].invest[0].reward = hourlyReward(value);
      users[_msgSender()].invest[0].endTime = block.timestamp.add(PERIOD_TIMES);
    } else {
      users[_msgSender()].invest.push(
        Invest(hourlyReward(value), block.timestamp.add(PERIOD_TIMES))
      );
    }
    payReferrer(users[_msgSender()].id, totalReward(value));
    emit UpdateUser(_msgSender(), value);
    return true;
  }

  function payReferrer(uint256 lastRefId, uint256 value) private {
    for (uint256 i = 0; i < 100; i++) {
      uint256 refParentId = users[userList[lastRefId]].refID;
      address userAddress = userList[refParentId];
      if (users[userAddress].id > 0 && !userExpired(userAddress)) {
        uint256 userReward = value.mul(users[userAddress].refPercent).div(10000);
        users[userAddress].refAmounts = users[userAddress].refAmounts.add(userReward);
      }
      if (refParentId == 0) break;
      lastRefId = refParentId;
    }
  }

  function withdrawInterest() public override returns (bool) {
    (uint256 hourly, uint256 referrals, uint256 savedTime) = calculateInterest(_msgSender());

    require(
      STT.payWithStt(_msgSender(), hourly.add(referrals)),
      "Error::Investment, Withdraw failed!"
    );

    users[_msgSender()].refAmounts = users[_msgSender()].refAmounts.sub(referrals);
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
    require(users[user].id > 0, "Error::Investment, User not exist!");
    requestTime = block.timestamp;
    (, , , uint256 satoshi) = userBalances(user);
    require(satoshi >= MINIMUM_INVEST, "Error::Investment, User dosen't have enough value!");

    referral = users[user].refAmounts;

    if (users[user].latestWithdraw <= requestTime) hourly = calculateHourly(user, requestTime);

    return (hourly, referral, requestTime);
  }

  function calculateHourly(address sender, uint256 time)
    internal
    view
    returns (uint256 hourly)
  {
    for (uint16 i; i < users[sender].invest.length; i++) {
      uint256 endTime = users[sender].invest[i].endTime;
      uint256 latestWithdraw = users[sender].latestWithdraw;
      if (latestWithdraw < endTime) {
        uint256 userHours = hoursBetween(time, latestWithdraw);
        if (userHours > PERIOD_HOURS) userHours = PERIOD_HOURS;
        hourly = hourly.add(userHours.mul(users[sender].invest[i].reward));
      }
    }
  }

  function userBalances(address user)
    public
    view
    override
    returns (
      uint256 bnb,
      uint256 btcb,
      uint256 stts,
      uint256 satoshi
    )
  {
    (, bnb, satoshi) = STT.userBalances(user, address(this));
    stts = STT.userTokens(user, address(this), STTS);
    btcb = STT.userTokens(user, address(this), BTCB);
  }

  function userDepositNumber(address user) public view override returns (uint256) {
    return users[user].invest.length;
  }

  function userDepositDetails(address user, uint256 index)
    public
    view
    override
    returns (uint256 reward, uint256 endTime)
  {
    reward = users[user].invest[index].reward;
    endTime = users[user].invest[index].endTime;
  }

  function userExpireTime(address user) public view override returns (uint256) {
    return users[user].invest[0].endTime;
  }

  function userExpired(address user) public view override returns (bool) {
    if (users[user].invest.length > 0) {
      return userExpireTime(user) <= block.timestamp;
    } else return true;
  }
}
