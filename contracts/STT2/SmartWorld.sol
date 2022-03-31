// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ISmartWorld.sol";
import "./IExternal.sol";
import "./Secure.sol";
import "./STT.sol";

contract SmartWorld is STT, ISmartWorld, Secure {
  using SafeMath for uint256;

  struct Assets {
    bool active;
    uint256 bnb;
    uint256 satoshi;
    mapping(address => uint256) tokens;
  }

  IExternal private bnbPair = IExternal(0x116EeB23384451C78ed366D4f67D5AD44eE771A0);
  IExternal private sttsPair = IExternal(0x45Ee99347E4E3946bE250fEC8172401965E2DFB3);

  address public BTCB = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
  address public STTS = 0x88469567A9e6b2daE2d8ea7D8C77872d9A0d43EC;

  mapping(address => mapping(address => Assets)) public override userBalances;

  constructor(address[] memory _devs) ERC20("Smart World Token", "STT") {
    devs = _devs;
    owner = _msgSender();
    devs.push(_msgSender());
  }

  function sttPrice() public view override returns (uint256) {
    (uint256 stts, uint256 btc, uint256 bnb) = totalSatoshi();
    return btc.add(stts).add(bnb).div(10**8);
  }

  function totalSatoshi()
    public
    view
    override
    returns (
      uint256 stts,
      uint256 btc,
      uint256 bnb
    )
  {
    (uint256 _stts, uint256 _btc, uint256 _bnb) = totalBalances();
    stts = sttsToSatoshi(_stts);
    btc = btcToSatoshi(_btc);
    bnb = bnbToSatoshi(_bnb);
  }

  function totalBalances()
    public
    view
    override
    returns (
      uint256 _stts,
      uint256 _btc,
      uint256 _bnb
    )
  {
    _stts = IERC20(STTS).balanceOf(address(this));
    _btc = IERC20(BTCB).balanceOf(address(this));
    _bnb = address(this).balance;
  }

  function btcToSatoshi(uint256 _value) public pure override returns (uint256) {
    return _value.div(10**10);
  }

  function bnbToSatoshi(uint256 _value) public view override returns (uint256) {
    return _value.mul(10**8).div(btcToBnbPrice());
  }

  function sttsToSatoshi(uint256 _value) public view override returns (uint256) {
    return bnbToSatoshi(sttsToBnb(_value));
  }

  function btcToBnbPrice() public view override returns (uint256) {
    return uint256(bnbPair.latestAnswer());
  }

  function sttsToBnb(uint256 _value) public view override returns (uint256) {
    return _value.mul(10**18).div(sttsToBnbPrice());
  }

  function sttsToBnbPrice() public view override returns (uint256) {
    (uint112 _reserve0, uint112 _reserve1, ) = sttsPair.getReserves();
    return uint256(_reserve0).mul(10**18).div(uint256(_reserve1));
  }

  function userTokens(
    address user_,
    address contract_,
    address token_
  ) public view override returns (uint256) {
    return userBalances[user_][contract_].tokens[token_];
  }

  function activation(address _user, uint256 airDrop)
    external
    override
    onlyFromContract
    returns (bool)
  {
    require(
      !userBalances[_user][_msgSender()].active,
      "Error::SmartWorld, deposit must be equal required TRX!"
    );

    userBalances[_user][_msgSender()].active = true;

    if (airDrop > 0) payWithStt(_user, airDrop);

    emit Activated(_msgSender(), _user);
    return true;
  }

  function deposit(address _sender, uint256 _value)
    external
    payable
    override
    onlyFromContract
    returns (bool)
  {
    require(msg.value == _value, "Error::SmartWorld, deposit must be equal required value!");

    uint256 satoshi = bnbToSatoshi(msg.value);
    userBalances[_sender][_msgSender()].active = true;
    userBalances[_sender][_msgSender()].bnb = userBalances[_sender][_msgSender()].bnb.add(
      msg.value
    );
    userBalances[_sender][_msgSender()].satoshi = userBalances[_sender][_msgSender()]
      .satoshi
      .add(satoshi);

    emit Deposit(_msgSender(), _sender, msg.value, satoshi);
    return true;
  }

  function withdraw(address payable _reciever, uint256 _interest)
    external
    override
    onlyFromContract
    returns (bool)
  {
    uint256 _balance = userBalances[_reciever][_msgSender()].bnb;
    require(_balance >= 0, "Error::SmartWorld, No previous deposit!");

    _reciever.transfer(_balance);

    if (_interest > 0) payWithStt(_reciever, _interest);

    userBalances[_reciever][_msgSender()].bnb = 0;
    userBalances[_reciever][_msgSender()].satoshi = 0;

    emit Withdraw(_msgSender(), _reciever, _balance);
    return true;
  }

  function depositToken(
    address _token,
    address _spender,
    uint256 _value
  ) external override onlyFromContract returns (bool) {
    require(
      IERC20(_token).balanceOf(_spender) >= _value,
      "Error::SmartWorld, user_ dosen't have enough Token!"
    );
    uint256 satoshi;
    if (_token == STTS) satoshi = sttsToSatoshi(_value);
    else if (_token == BTCB) satoshi = btcToSatoshi(_value);

    _safeTransferFrom(_token, _spender, address(this), _value);

    userBalances[_spender][_msgSender()].active = true;
    userBalances[_spender][_msgSender()].tokens[_token] = userBalances[_spender][_msgSender()]
      .tokens[_token]
      .add(_value);
    userBalances[_spender][_msgSender()].satoshi = userBalances[_spender][_msgSender()]
      .satoshi
      .add(satoshi);

    emit DepositToken(_token, _msgSender(), _spender, _value);
    return true;
  }

  function withdrawToken(
    address _token,
    address _reciever,
    uint256 _interest
  ) external override onlyFromContract returns (bool) {
    uint256 _balance = userBalances[_reciever][_msgSender()].tokens[_token];
    require(_balance > 0, "Error::SmartWorld, No previous deposit!");

    _safeTransfer(_token, _reciever, _balance);

    if (_interest > 0) {
      payWithStt(_reciever, _interest);
    }

    userBalances[_reciever][_msgSender()].tokens[_token] = 0;
    userBalances[_reciever][_msgSender()].satoshi = 0;

    emit WithdrawToken(_token, _msgSender(), _reciever, _balance);
    return true;
  }

  function payWithStt(address _reciever, uint256 _interest)
    public
    override
    onlyFromContract
    returns (bool)
  {
    require(
      userBalances[_reciever][_msgSender()].active,
      "Error::SmartWorld, No previous deposit!"
    );
    super._mint(_reciever, _interest);
    return true;
  }

  function burnWithStt(address _from, uint256 _amount)
    public
    override
    onlyFromContract
    returns (bool)
  {
    require(balanceOf(_from) >= _amount, "Error::SmartWorld, No previous deposit!");
    super._burn(_from, _amount);
    return true;
  }

  function withdrawBnbByVote(uint256 _value) public voteByDevs(_value) {
    require(onVote.nominate == owner, "Error::SmartWorld, Nothing on the Vote!");
    payable(owner).transfer(onVote.value);
  }

  function withdrawTokenByVote(address _token, uint256 _value) public voteByDevs(_value) {
    require(onVote.nominate == owner, "Error::SmartWorld, Nothing on the Vote!");
    _safeTransfer(_token, owner, _value);
  }
}
