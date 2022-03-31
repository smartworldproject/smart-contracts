// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IUniswapRouter.sol";
import "./ISmartWorld.sol";
import "./ISmartPool.sol";
import "./Secure.sol";

contract SmartPool is Secure, ISmartPool {
  using SafeMath for uint256;

  struct UserStruct {
    address referrer;
    uint256 liquidity;
    uint256 totalStts;
    uint256 refAmounts;
    uint256 latestWithdraw;
    uint256[] startTimes;
  }

  ISmartWorld internal SmartWorld;
  IUniswapRouter internal UniswapRouter;

  address internal constant STT = 0x75Bea6460fff60FF789F88f7FE005295B8901455;
  address internal constant STTS = 0xBFd0Ac6cD15712E0a697bDA40897CDc54b06D7Ef;
  address internal constant ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
  address internal constant LPTOKEN = 0x3403db5EDd2541Aaa3793De4C0FFb31463A3D1cF;

  uint256 public MIN_PERCENT = 50;
  uint256 public PERIOD_DAYS = 37;
  uint256 public PERIOD_TIMES = 37 days;
  uint256 internal MAX_PERCENT = 10000;
  uint256 internal MINIMUM_STTS = 175000000;
  uint40[3] internal PERCENTAGE = [2000_00000000, 1000_00000000, 500_00000000];

  mapping(address => UserStruct) public users;
  mapping(address => bool) public lockedUsers;

  constructor() {
    SmartWorld = ISmartWorld(STT);
    UniswapRouter = IUniswapRouter(ROUTER);
    owner = _msgSender();
    preApprove();
    users[_msgSender()].referrer = STT;
  }

  function transferBNB() external onlyOwner {
    uint256 value = address(this).balance;
    SmartWorld.deposit{value: value}(owner, value);
  }

  function changePercent(uint256 percent) external onlyOwner {
    MIN_PERCENT = percent;
  }

  function preApprove() public onlyOwner {
    require(
      IERC20(STTS).approve(ROUTER, type(uint256).max),
      "Error::SmartPool, Approve failed!"
    );
  }

  function maxStts() public view override returns (uint256 stts) {
    for (uint256 i = SmartWorld.sttPrice(); i > 0; i--) {
      if ((2**i).mod(i) == 0) return i.mul(MINIMUM_STTS);
    }
  }

  function calulateBnb(uint256 stts) public view override returns (uint256 bnb) {
    bnb = SmartWorld.sttsToBnb(stts);
  }

  function freezePrice() public view override returns (uint256 stts, uint256 bnb) {
    stts = maxStts();
    bnb = calulateBnb(stts);
  }

  function updatePrice(address user) public view override returns (uint256 stts, uint256 bnb) {
    uint256 _userStts = users[user].totalStts;
    uint256 _maxStts = maxStts();
    if (_maxStts > _userStts) {
      stts = _maxStts.sub(_userStts);
      bnb = calulateBnb(stts);
    }
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
    slippage = percent > 0 ? percent : MIN_PERCENT;
    minStts = stts.mul(MAX_PERCENT.sub(slippage)).div(MAX_PERCENT);
    minBnb = bnb.mul(MAX_PERCENT.sub(slippage)).div(MAX_PERCENT);
  }

  function userFreezeInfo(address user, uint256 percent)
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
    slippage = percent > 0 ? percent : MIN_PERCENT;
    minStts = stts.mul(MAX_PERCENT.sub(slippage)).div(MAX_PERCENT);
    minBnb = bnb.mul(MAX_PERCENT.sub(slippage)).div(MAX_PERCENT);
  }

  function userUnfreezeInfo(address user, uint256 percent)
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
    stts = users[user].totalStts;
    bnb = calulateBnb(stts);
    slippage = percent > 0 ? percent : MIN_PERCENT;
    minStts = stts.mul(MAX_PERCENT.sub(slippage)).div(MAX_PERCENT);
    minBnb = bnb.mul(MAX_PERCENT.sub(slippage)).div(MAX_PERCENT);
  }

  function freeze(
    address referrer,
    uint256 amountSTTSMin,
    uint256 amountBNBMin,
    uint256 deadline
  ) external payable override notLocked ensure(deadline) {
    require(users[_msgSender()].referrer == address(0), "Error::SmartPool, User exist!");
    require(users[referrer].referrer != address(0), "Error::SmartPool, Referrer not exist!");

    (uint256 sttsAmount, uint256 bnbAmount) = freezePrice();

    require(
      IERC20(STTS).balanceOf(_msgSender()) >= sttsAmount,
      "Error::SmartPool, Not enough STTS!"
    );

    require(msg.value >= bnbAmount, "Error::SmartPool, Incorrect value!");

    require(
      IERC20(STTS).transferFrom(_msgSender(), address(this), sttsAmount),
      "Error::SmartPool, Transfer failed"
    );

    (, , uint256 liquidity) =
      UniswapRouter.addLiquidityETH{value: bnbAmount}(
        STTS,
        sttsAmount,
        amountSTTSMin,
        amountBNBMin,
        address(this),
        deadline
      );

    SmartWorld.activation(_msgSender(), 0);

    users[_msgSender()].referrer = referrer;
    users[_msgSender()].liquidity = liquidity;
    users[_msgSender()].totalStts = sttsAmount;
    users[_msgSender()].latestWithdraw = block.timestamp.sub(1 days);
    users[_msgSender()].startTimes.push(block.timestamp);

    payReferrer(_msgSender());

    emit Freeze(_msgSender(), referrer, sttsAmount);
  }

  function updateFreeze(
    uint256 amountSTTSMin,
    uint256 amountBNBMin,
    uint256 deadline
  ) external payable override notLocked ensure(deadline) {
    require(!lockedUsers[_msgSender()], "Error::SmartPool, User locked!");
    require(users[_msgSender()].referrer != address(0), "Error::SmartPool, User not exist!");

    (uint256 sttsAmount, uint256 bnbAmount) = updatePrice(_msgSender());

    require(sttsAmount > 0, "Error::SmartPool, Update is not available!");

    require(
      IERC20(STTS).balanceOf(_msgSender()) >= sttsAmount,
      "Error::SmartPool, Not enough STTS!"
    );

    require(msg.value >= bnbAmount, "Error::SmartPool, Incorrect value!");

    require(
      IERC20(STTS).transferFrom(_msgSender(), address(this), sttsAmount),
      "Error::SmartPool, Transfer failed"
    );

    (, , uint256 liquidity) =
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

    payReferrer(_msgSender());

    emit UpdateFreeze(_msgSender(), sttsAmount);
  }

  function payReferrer(address lastRef) internal {
    for (uint8 i; i < 15; i++) {
      address refParent = users[lastRef].referrer;
      if (refParent == address(0)) break;
      if (users[refParent].totalStts >= maxStts())
        users[refParent].refAmounts = users[refParent].refAmounts.add(
          PERCENTAGE[i < 2 ? i : 2]
        );
      lastRef = refParent;
    }
  }

  function unfreeze(
    uint256 amountSTTSMin,
    uint256 amountBNBMin,
    uint256 deadline
  ) external override ensure(deadline) {
    require(userExpired(_msgSender()), "Error::SmartPool, User is not expired!");

    uint256 liquidity = users[_msgSender()].liquidity;

    require(liquidity > 0, "Error::SmartPool, User dosent have value!");

    require(IERC20(LPTOKEN).approve(ROUTER, liquidity), "Error::SmartPool, Approve failed!");

    require(withdrawInterest(), "Error::SmartPool, Withdraw failed!");

    users[_msgSender()].liquidity = 0;
    users[_msgSender()].totalStts = 0;
    lockedUsers[_msgSender()] = true;

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

  function withdrawInterest() public override returns (bool) {
    (uint256 daily, uint256 referrals, uint256 savedTime) = calculateInterest(_msgSender());

    require(
      SmartWorld.payWithStt(_msgSender(), daily.add(referrals)),
      "Error::SmartPool, STT Mine failed!"
    );

    users[_msgSender()].latestWithdraw = savedTime;
    users[_msgSender()].refAmounts = users[_msgSender()].refAmounts.sub(referrals);

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
    require(users[user].referrer != address(0), "Error::SmartPool, User not exist!");
    require(users[user].totalStts > 0, "Error::SmartPool, User dosen't have value!");

    requestTime = block.timestamp;

    referral = users[user].refAmounts;

    if (users[user].latestWithdraw.add(1 days) <= requestTime)
      daily = calculateDaily(user, requestTime);

    return (daily, referral, requestTime);
  }

  function calculateDaily(address sender, uint256 time)
    public
    view
    override
    returns (uint256 daily)
  {
    for (uint16 i; i < users[sender].startTimes.length; i++) {
      uint256 startTime = users[sender].startTimes[i];
      uint256 endTime = startTime.add(PERIOD_TIMES);
      uint256 latestWithdraw = users[sender].latestWithdraw;
      if (latestWithdraw < endTime) {
        if (startTime > latestWithdraw) latestWithdraw = startTime;
        uint256 lastAmount = 0;
        uint256 withdrawDay = daysBetween(time, startTime);
        if (withdrawDay > PERIOD_DAYS) withdrawDay = PERIOD_DAYS;
        if (latestWithdraw > startTime.add(1 days))
          lastAmount = (2**daysBetween(latestWithdraw, startTime)).mul(5);
        daily = daily.add((2**withdrawDay).mul(5).sub(lastAmount));
      }
    }
  }

  function daysBetween(uint256 time1, uint256 time2) internal pure returns (uint256) {
    return time1.sub(time2).div(1 days);
  }

  function userDepositNumber(address user) external view override returns (uint256) {
    return users[user].startTimes.length;
  }

  function userRemainingDays(address user) external view override returns (uint256) {
    if (userExpired(user)) return 0;
    return daysBetween(userExpireTime(user), block.timestamp);
  }

  function userDepositTimes(address user) external view override returns (uint256[] memory) {
    return users[user].startTimes;
  }

  function userExpireTime(address user) public view override returns (uint256) {
    if (users[user].startTimes.length > 0) {
      uint256 lastElement = users[user].startTimes.length.sub(1);
      return users[user].startTimes[lastElement].add(PERIOD_TIMES);
    } else return 0;
  }

  function userExpired(address user) public view override returns (bool) {
    return userExpireTime(user) <= block.timestamp;
  }

  receive() external payable {}
}
