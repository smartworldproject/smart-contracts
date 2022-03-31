// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISmartWorld {
  function sttPrice() external view returns (uint256);

  function STTS() external view returns (address);

  function BTCB() external view returns (address);

  function totalSupply() external view returns (uint256);

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
    address token_,
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
