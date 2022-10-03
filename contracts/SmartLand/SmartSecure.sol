// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract SmartSecure is Context {
  event Paused(address account);
  event Unpaused(address account);
  event AddedBlackList(address indexed user);
  event RemovedBlackList(address indexed user);
  event ReferralReceived(address indexed user, address from, uint256 value);

  modifier onlyOwner() {
    require(owner == _msgSender(), "Error::SmartSecure, Only from Owner");
    _;
  }

  modifier onlyGameMaster() {
    require(gameMaster == _msgSender(), "Error::SmartSecure, Only from Game Master");
    _;
  }

  bool internal PAUSED;

  string internal BASE_URL =
    "ipfs://bafybeihet3fxfc7pua5bclg37aafgoohbxxsvobfohxcdk7mljz2l22uoi/";
  string internal BASE_EXT = ".json";

  address public owner;

  address public gameMaster;

  uint256 public LAND_PRICE = 500000000000000000;

  uint256 public REFERRAL_PERCENT = 25;

  mapping(address => bool) public blacklist;

  mapping(uint256 => bytes) public landData;

  function _safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{gas: 23000, value: value}("");

    require(success, "Error::SmartSecure, Transfer Failed!");
  }

  //only owner
  function pause() public onlyOwner {
    PAUSED = true;
    emit Paused(_msgSender());
  }

  function unpause() public onlyOwner {
    PAUSED = false;
    emit Unpaused(_msgSender());
  }

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

  function setOwner(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Error::SmartSecure, Zero Address!");
    owner = newOwner;
  }

  function setGameMaster(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Error::SmartSecure, Zero Address!");
    gameMaster = newOwner;
  }

  function updateLandData(uint256 tokenId, bytes memory data) public onlyGameMaster {
    landData[tokenId] = data;
  }

  function updateBatchLandData(uint256[] memory tokenIds, bytes[] memory data)
    public
    onlyGameMaster
  {
    require(tokenIds.length == data.length, "Error::SmartSecure, Incorrect Data!");
    for (uint256 i = 0; i < tokenIds.length; i++) {
      uint256 tokenId = tokenIds[i];
      landData[tokenId] = data[i];
    }
  }

  function addBlackList(address user) external onlyOwner {
    blacklist[user] = true;
    emit AddedBlackList(user);
  }

  function removeBlackList(address user) external onlyOwner {
    blacklist[user] = false;
    emit RemovedBlackList(user);
  }
}
