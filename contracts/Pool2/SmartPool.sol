// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IUniswapRouter.sol";
import "./ISmartWorld.sol";
import "./ISmartPool.sol";
import "./Secure.sol";

contract SmartPool is Secure, ISmartPool {
  using SafeMath for uint256;

  struct UserStruct {
    uint256 id;
    uint256 refID;
    uint256 liquidity;
    uint256 totalStts;
    uint256 refAmounts;
    address[] referrals;
    uint256[] startTimes;
    uint32[15] refStates;
    uint256 latestWithdraw;
  }

  IUniswapRouter internal UniswapRouter;
  ISmartWorld internal SmartWorld;

  address public constant STT = 0x75Bea6460fff60FF789F88f7FE005295B8901455;
  address public constant STTS = 0xBFd0Ac6cD15712E0a697bDA40897CDc54b06D7Ef;
  address public constant ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
  address public constant LPTOKEN = 0x3403db5EDd2541Aaa3793De4C0FFb31463A3D1cF;

  uint256 public MAX_PERCENT = 10000;
  uint256 public MAX_SLIPPAGE = 50;

  uint8 private LEVEL_1_LIMIT = 3;
  uint256 private PERIOD_DAYS = 37;
  uint256 private MINIMUM_STTS = 350000000;
  uint256 private PERIOD_TIMES = 37 minutes;
  uint16[5] private LEVELS = [3, 9, 27, 81, 243];
  uint40[3] private PERCENTAGE = [20615843616, 13743895725, 6871947862];

  uint256 public userID = 1;
  mapping(address => UserStruct) public users;
  mapping(uint256 => address) private userList;

  constructor() {
    SmartWorld = ISmartWorld(STT);
    UniswapRouter = IUniswapRouter(ROUTER);
    require(
      IERC20(STTS).approve(ROUTER, type(uint256).max),
      "Error::SmartPool, Approve failed!"
    );
    owner = _msgSender();

    users[_msgSender()].id = userID;
    userList[userID] = _msgSender();
  }

  function setPercent(uint256 _percent) public onlyOwner {
    MAX_SLIPPAGE = _percent;
  }

  function daysBetween(uint256 time1, uint256 time2) internal pure returns (uint256) {
    return time1.sub(time2).div(1 minutes);
  }

  function maxStts() public view override returns (uint256 stts) {
    for (uint256 i = SmartWorld.sttPrice(); i > 0; i--) {
      if ((2**i).mod(i) == 0) return i.mul(MINIMUM_STTS);
    }
  }

  function freezePrice() public view override returns (uint256 stts, uint256 bnb) {
    stts = maxStts();
    bnb = SmartWorld.sttsToBnb(stts);
  }

  function updatePrice(address user) public view override returns (uint256 stts, uint256 bnb) {
    stts = maxStts().sub(users[user].totalStts);
    bnb = SmartWorld.sttsToBnb(stts);
  }

  function calulateBnb(uint256 stts) public view override returns (uint256 bnb) {
    bnb = SmartWorld.sttsToBnb(stts);
  }

  function priceInfo(uint256 stts, uint256 percent)
    external
    view
    override
    returns (
      uint256 bnb,
      uint256 minStts,
      uint256 minBnb,
      uint256 slippage
    )
  {
    bnb = calulateBnb(stts);
    slippage = percent > 0 ? percent : MAX_SLIPPAGE;
    minStts = stts.mul(uint256(MAX_PERCENT).sub(slippage)).div(MAX_PERCENT);
    minBnb = bnb.mul(uint256(MAX_PERCENT).sub(slippage)).div(MAX_PERCENT);
  }

  function freezePriceInfo(address user, uint256 percent)
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
    (stts, bnb) = user != address(0) ? updatePrice(user) : freezePrice();
    slippage = percent > 0 ? percent : MAX_SLIPPAGE;
    minStts = stts.mul(uint256(MAX_PERCENT).sub(slippage)).div(MAX_PERCENT);
    minBnb = bnb.mul(uint256(MAX_PERCENT).sub(slippage)).div(MAX_PERCENT);
  }

  function freeze(
    address referrer,
    uint256 amountSTTSMin,
    uint256 amountBNBMin,
    uint256 deadline
  ) external payable override {
    require(users[_msgSender()].id == 0, "Error::SmartPool, User exist!");
    (uint256 sttsAmount, uint256 bnbAmount) = freezePrice();

    require(
      IERC20(STTS).balanceOf(_msgSender()) >= sttsAmount,
      "Error::SmartPool, Not enough STTS!"
    );

    require(msg.value >= bnbAmount, "Error::SmartPool, Incorrect value!");

    uint256 refID;

    if (users[referrer].id > 0) refID = users[referrer].id;
    else if (referrer == address(0)) refID = findMostFreeRandomReferrer();
    else revert("Error::SmartPool, Referrer not found!");

    require(refID > 0 && refID <= userID, "Error::SmartPool, Incorrect referrer id!");

    if (users[userList[refID]].referrals.length >= LEVEL_1_LIMIT)
      refID = users[findMostFreeReferrals(userList[refID])].id;

    require(
      IERC20(STTS).transferFrom(_msgSender(), address(this), sttsAmount),
      "Error::SmartPool, Transfer failed"
    );

    (, uint256 amountBnb, uint256 liquidity) =
      UniswapRouter.addLiquidityETH{value: bnbAmount}(
        STTS,
        sttsAmount,
        amountSTTSMin,
        amountBNBMin,
        address(this),
        deadline
      );

    userID = userID.add(1);

    users[_msgSender()].id = userID;
    users[_msgSender()].refID = refID;
    users[_msgSender()].liquidity = liquidity;
    users[_msgSender()].totalStts = sttsAmount;
    users[_msgSender()].startTimes.push(block.timestamp);

    userList[userID] = _msgSender();

    users[userList[refID]].referrals.push(_msgSender());

    SmartWorld.activation(_msgSender(), 0);

    payReferrer(userID);

    if (msg.value > amountBnb) payable(_msgSender()).transfer(msg.value - amountBnb);

    emit Freeze(_msgSender(), userList[refID], sttsAmount);
  }

  function updateFreeze(
    uint256 amountSTTSMin,
    uint256 amountBNBMin,
    uint256 deadline
  ) external payable override {
    require(users[_msgSender()].id > 0, "Error::SmartPool, User not exist!");

    (uint256 sttsAmount, uint256 bnbAmount) = updatePrice(_msgSender());

    if (sttsAmount == 0)
      require(userExpired(_msgSender()), "Error::SmartPool, User is not expired!");

    require(
      IERC20(STTS).balanceOf(_msgSender()) >= sttsAmount,
      "Error::SmartPool, Not enough STTS!"
    );

    require(msg.value >= bnbAmount, "Error::SmartPool, Incorrect value!");

    require(
      IERC20(STTS).transferFrom(_msgSender(), address(this), sttsAmount),
      "Error::SmartPool, Transfer failed"
    );
    (, uint256 amountBnb, uint256 liquidity) =
      UniswapRouter.addLiquidityETH{value: bnbAmount}(
        STTS,
        sttsAmount,
        amountSTTSMin,
        amountBNBMin,
        address(this),
        deadline
      );

    users[_msgSender()].liquidity = users[_msgSender()].liquidity.add(liquidity);
    users[_msgSender()].totalStts = users[_msgSender()].totalStts.add(sttsAmount);
    users[_msgSender()].startTimes.push(block.timestamp);

    payReferrer(users[_msgSender()].id);

    if (msg.value > amountBnb) payable(_msgSender()).transfer(msg.value - amountBnb);

    emit UpdateFreeze(_msgSender(), sttsAmount);
  }

  function unfreeze(
    uint256 amountSTTSMin,
    uint256 amountBNBMin,
    uint256 deadline
  ) external override {
    require(userExpired(_msgSender()), "Error::SmartPool, User is not expired!");

    uint256 liquidity = users[_msgSender()].liquidity;

    require(liquidity > 0, "Error::SmartPool, User dosent have value!");

    require(IERC20(LPTOKEN).approve(ROUTER, liquidity), "Error::SmartPool, Approve failed!");

    require(withdrawInterest(), "Error::SmartPool, Withdraw failed!");

    users[_msgSender()].liquidity = 0;
    users[_msgSender()].totalStts = 0;

    (uint256 amountToken, uint256 amountBNB) =
      UniswapRouter.removeLiquidityETH(
        STTS,
        liquidity,
        amountSTTSMin,
        amountBNBMin,
        _msgSender(),
        deadline
      );

    emit Unfreeze(_msgSender(), amountToken, amountBNB);
  }

  function payReferrer(uint256 lastRefId) internal {
    for (uint256 i = 0; i < 15; i++) {
      uint256 refParentId = users[userList[lastRefId]].refID;
      address userAddress = userList[refParentId];
      if (refParentId != lastRefId) {
        users[userAddress].refStates[i] = users[userAddress].refStates[i] + 1;
        if (!userExpired(userAddress) && users[userAddress].totalStts >= maxStts())
          users[userAddress].refAmounts = users[userAddress].refAmounts.add(
            PERCENTAGE[i < 2 ? i : 2]
          );
      }
      lastRefId = refParentId;
      if (refParentId == 0) break;
    }
  }

  function withdrawInterest() public override returns (bool) {
    (uint256 daily, uint256 referrals, uint256 savedTime) = calculateInterest(_msgSender());

    require(
      SmartWorld.payWithStt(_msgSender(), daily.add(referrals)),
      "Error::SmartPool, STT Mine failed!"
    );

    users[_msgSender()].refAmounts = users[_msgSender()].refAmounts.sub(referrals);
    users[_msgSender()].latestWithdraw = savedTime;

    emit WithdrawInterest(_msgSender(), daily, referrals);
    return true;
  }

  function calculateInterest(address user)
    public
    view
    override
    returns (
      uint256 daily,
      uint256 referral,
      uint256 requestTime
    )
  {
    require(users[user].id > 0, "Error::SmartPool, User not exist!");

    require(users[user].totalStts > 0, "Error::SmartPool, User dosen't have value!");

    requestTime = block.timestamp;

    referral = users[user].refAmounts;

    if (users[user].latestWithdraw.add(1 minutes) <= requestTime)
      daily = calculateDaily(user, requestTime);
  }

  function calculateDaily(address sender, uint256 time) internal view returns (uint256 daily) {
    for (uint16 i; i < users[sender].startTimes.length; i++) {
      uint256 startTime = users[sender].startTimes[i];
      uint256 endTime = startTime.add(PERIOD_TIMES);
      uint256 latestWithdraw = users[sender].latestWithdraw;
      if (latestWithdraw < endTime) {
        if (startTime > latestWithdraw) latestWithdraw = startTime;
        uint256 lastAmount = 0;
        uint256 withdrawDay = daysBetween(time, startTime);
        if (withdrawDay > PERIOD_DAYS) withdrawDay = PERIOD_DAYS;
        if (latestWithdraw > startTime.add(1 minutes))
          lastAmount = (2**daysBetween(latestWithdraw, startTime)).mul(5);
        daily = daily.add((2**withdrawDay).mul(5).sub(lastAmount));
      }
    }
  }

  function findMostFreeReferrals(address _user) public view returns (address) {
    if (users[_user].referrals.length < LEVEL_1_LIMIT) return _user;

    uint8 currentLevel = userCompletedLevel(_user);
    address freeReferrer;

    if (currentLevel != 0) {
      (uint16 members, uint16 startLoop) = totalMembers(currentLevel);
      address[] memory referrals = new address[](members);

      referrals[0] = users[_user].referrals[0];
      referrals[1] = users[_user].referrals[1];
      referrals[2] = users[_user].referrals[2];

      for (uint16 i; i < startLoop; i++) {
        for (uint8 m; m < 3; m++) {
          referrals[(i + 1) * 3 + m] = users[referrals[i]].referrals[m];
        }
      }

      for (uint8 l; l < 3; l++) {
        for (uint16 k = startLoop; k < members; k++) {
          if (users[referrals[k]].referrals.length == l) {
            freeReferrer = referrals[k];
            break;
          }
        }
        if (freeReferrer != address(0)) break;
      }
    }
    if (freeReferrer == address(0)) freeReferrer = userList[findMostFreeRandomReferrer()];

    return freeReferrer;
  }

  function findMostFreeRandomReferrer() public view returns (uint256 ref) {
    for (uint8 l; l < 3; l++) {
      for (uint256 i = userID.div(2); i < userID.div(2).add(100); i++) {
        if (users[userList[i]].referrals.length == l) return i;
      }
    }
  }

  function totalMembers(uint8 level) internal view returns (uint16 members, uint16 startLoop) {
    if (level == 1) return (3, 0);
    for (uint8 i; i < level; i++) {
      if (i > 0) startLoop = startLoop + LEVELS[i - 1];
      members = members + LEVELS[i];
    }
    return (members, startLoop);
  }

  function userCompletedLevel(address _user) public view override returns (uint8 level) {
    for (uint8 i; i < LEVELS.length; i++) {
      if (users[_user].refStates[i] < LEVELS[i]) {
        return i;
      }
    }
  }

  function userReferralList(address user) external view override returns (uint32[15] memory) {
    return users[user].refStates;
  }

  function userDepositNumber(address user) external view override returns (uint256) {
    return users[user].startTimes.length;
  }

  function userDepositTimer(address user, uint256 index)
    external
    view
    override
    returns (uint256)
  {
    return daysBetween(block.timestamp, users[user].startTimes[index]);
  }

  function userDepositTime(address user) external view override returns (uint256[] memory) {
    return users[user].startTimes;
  }

  function userReferrals(address user) external view override returns (address[] memory) {
    return users[user].referrals;
  }

  function userExpireTime(address user) public view override returns (uint256) {
    uint256 lastElement = users[user].startTimes.length.sub(1);
    return users[user].startTimes[lastElement].add(PERIOD_TIMES);
  }

  function userExpired(address user) public view override returns (bool) {
    if (users[user].startTimes.length > 0) {
      return userExpireTime(user) <= block.timestamp;
    } else return true;
  }

  receive() external payable {}
}
