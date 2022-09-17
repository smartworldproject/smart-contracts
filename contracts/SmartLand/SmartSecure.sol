// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

abstract contract SmartSecure is Ownable, Pausable {
  event AddedBlackList(address indexed user);
  event RemovedBlackList(address indexed user);

  bool internal locked;

  string internal BASE_URL =
    "ipfs://bafybeigqzp3iulfmhrnrrhssfbehzompxkv5g4xgsghcjzn3jic5bkukca/";
  string internal BASE_EXT = ".json";

  uint256 public LAND_PRICE = 1 ether;

  uint256 public REFERRAL_PERCENT = 25;

  mapping(address => bool) public blacklist;

  modifier nonReentrant() {
    require(!blacklist[_msgSender()], "BLK");
    require(!locked, "LCK");
    locked = true;
    _;
    locked = false;
  }

  function transferToOwner() internal {
    _safeTransferETH(owner(), LAND_PRICE);
  }

  function _safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{gas: 23000, value: value}("");

    require(success, "ETH");
  }

  function pause() public onlyOwner {
    _pause();
  }

  function unpause() public onlyOwner {
    _unpause();
  }

  //only owner
  function setPrice(uint256 newPrice) public onlyOwner {
    LAND_PRICE = newPrice;
  }

  function setBaseURI(string memory newBaseURI) public onlyOwner {
    BASE_URL = newBaseURI;
  }

  function setBaseExtension(string memory newBaseExt) public onlyOwner {
    BASE_EXT = newBaseExt;
  }

  function setReferralPercent(uint32 percent) external onlyOwner {
    REFERRAL_PERCENT = percent;
  }

  function addBlackList(address user) external onlyOwner {
    blacklist[user] = true;
    emit AddedBlackList(user);
  }

  function removeBlackList(address user) external onlyOwner {
    blacklist[user] = false;
    emit RemovedBlackList(user);
  }

  function withdrawBnb(uint256 value) external onlyOwner {
    payable(owner()).transfer(value);
  }
}
