// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISmartWorld {
  event Activated(address indexed by, address indexed user);

  event Withdraw(address indexed from, address indexed user, uint256 amount);

  event Deposit(address indexed by, address indexed user, uint256 satoshi, uint256 amount);

  event DepositToken(
    address indexed token,
    address indexed by,
    address indexed user,
    uint256 amount
  );
  event WithdrawToken(
    address indexed token,
    address indexed from,
    address indexed user,
    uint256 amount
  );

  function sttPrice() external view returns (uint256);

  function totalSatoshi()
    external
    view
    returns (
      uint256 stts,
      uint256 btc,
      uint256 bnb
    );

  function totalBalances()
    external
    view
    returns (
      uint256 stts,
      uint256 btc,
      uint256 bnb
    );

  function btcToSatoshi(uint256 value_) external view returns (uint256);

  function bnbToSatoshi(uint256 value_) external view returns (uint256);

  function sttsToSatoshi(uint256 value_) external view returns (uint256);

  function btcToBnbPrice() external view returns (uint256);

  function sttsToBnb(uint256 value_) external view returns (uint256);

  function sttsToBnbPrice() external view returns (uint256);

  function userBalances(address user_, address contract_)
    external
    view
    returns (
      bool isActive,
      uint256 bnb,
      uint256 satoshi
    );

  function userTokens(
    address token,
    address user_,
    address contract_
  ) external view returns (uint256);

  function activation(address sender_, uint256 airDrop_) external returns (bool);

  function deposit(address sender_, uint256 value_) external payable returns (bool);

  function withdraw(address payable reciever_, uint256 interest_) external returns (bool);

  function depositToken(
    address token_,
    address spender_,
    uint256 value_
  ) external returns (bool);

  function withdrawToken(
    address token_,
    address reciever_,
    uint256 interest_
  ) external returns (bool);

  function payWithStt(address reciever_, uint256 interest_) external returns (bool);

  function burnWithStt(address from_, uint256 amount_) external returns (bool);
}
