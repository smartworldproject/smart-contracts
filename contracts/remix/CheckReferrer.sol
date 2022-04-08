// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISmartInvest04 {
  function users(address user) external view returns (address referrer);
}

contract InvestReferrer {
  ISmartInvest04 internal Invest04 =
    ISmartInvest04(0xeB2F87B4fF2C35bf1a56B97bAd9bd8Bbf06768bA);

  function checkUser(address user) public view returns (address) {
    address referrer = Invest04.users(user);
    if (referrer != address(0)) return checkUser(referrer);
    else return user;
  }

  function checkUserList(address[] memory users) public view returns (address[] memory) {
    address[] memory needMigrate = new address[](users.length);
    for (uint256 i = 0; i < users.length; i++) {
      address user = checkUser(users[i]);
      needMigrate[i] = user;
    }
    return needMigrate;
  }
}
