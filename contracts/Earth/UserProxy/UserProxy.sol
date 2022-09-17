// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./IUserData.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract UserProxy is Ownable {
  IUserData private UserData = IUserData(0x39F1873cE8734a7D54038e2F78ac2a0deB7D336E);

  // Registeration functions ----------------------------------------------------------
  function payReferrer(
    address lastRef,
    uint64 value,
    uint8 level
  ) public onlyOwner returns (bool) {
    return UserData.payReferrer(lastRef, value, level);
  }

  // Modifier list functions ----------------------------------------------------------
  function removeInvestList(address[] memory users) external onlyOwner {
    for (uint8 i = 0; i < users.length; i++) {
      UserData.deleteUser(users[i]);
    }
    UserData.removeListBlacklist(users);
  }

  function addGiftAmountList(address[] memory user, uint256[] memory gift) external onlyOwner {
    for (uint8 i = 0; i < user.length; i++) {
      UserData.addGiftAmount(user[i], gift[i]);
    }
  }

  function addRefAmountList(address[] memory user, uint256[] memory amount)
    external
    onlyOwner
  {
    for (uint8 i = 0; i < user.length; i++) {
      UserData.addRefAmount(user[i], amount[i]);
    }
  }
}
