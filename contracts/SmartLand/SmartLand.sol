// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./SmartSecure.sol";
import "./SmartUint.sol";

contract SmartLand is ERC721Enumerable, SmartSecure {
  using SmartUint for uint256;

  constructor() ERC721("SmartLand", "STL") {
    owner = msg.sender;
    gameMaster = msg.sender;
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    return string(abi.encodePacked(BASE_URL, tokenId.toString(), BASE_EXT));
  }

  function mint(
    address referrer,
    uint256 tokenId,
    bytes memory data
  ) public payable {
    require(isMintable(tokenId), "Error::SmartLand, Invalid Token ID");
    require(msg.value >= LAND_PRICE, "Error::SmartLand, Insufficient Funds");
    require(data.length == 16, "Error::SmartLand, Incorrect Data!");

    uint256 refAmount = 0;

    if (!isUser(_msgSender()) && isUser(referrer)) {
      refAmount = LAND_PRICE.percent(REFERRAL_PERCENT);
      _safeTransferETH(referrer, refAmount);

      emit ReferralReceived(referrer, _msgSender(), refAmount);
    }

    landData[tokenId] = data;

    _safeTransferETH(owner, msg.value.sub(refAmount));

    _safeMint(msg.sender, tokenId);
  }

  function isMintable(uint256 tokenId) public view returns (bool) {
    return !_exists(tokenId) && tokenId > 0 && tokenId <= 10000;
  }

  function isUser(address user) public view returns (bool) {
    if (user == address(0)) return false;
    return balanceOf(user) > 0 && !blacklist[user];
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal override {
    if (from != address(0)) {
      require(!PAUSED, "Error::SmartLand, Transfer Paused!");
    }

    super._beforeTokenTransfer(from, to, tokenId);
  }
}
