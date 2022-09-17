// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./SmartSecure.sol";
import "./SmartUint.sol";

contract SmartLand is ERC721Enumerable, SmartSecure {
  using SmartUint for uint256;

  event ReferralReceived(address indexed user, address from, uint256 value);

  struct UserStruct {
    address referrer;
    uint256 refAmounts;
  }

  mapping(address => UserStruct) public users;
  mapping(uint256 => bytes) public landDetail;

  uint256 maxSupply = 10_000;

  constructor() ERC721("SmartLand", "STL") {}

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    return string(abi.encodePacked(BASE_URL, tokenId.toString(), BASE_EXT));
  }

  function mint(
    address referrer,
    uint256 tokenId,
    bytes memory details
  ) public payable {
    require(tokenId < maxSupply && !_exists(tokenId), "NOT");
    require(totalSupply() <= maxSupply, "MAX");
    require(msg.value >= LAND_PRICE, "ETH");
    transferToOwner();

    landDetail[tokenId] = details;

    if (!exists(_msgSender())) {
      if (exists(referrer)) {
        users[_msgSender()].referrer = referrer;

        payReferrer(users[_msgSender()].referrer);
      } else {
        users[_msgSender()].referrer = address(1);
      }
    }

    _safeMint(msg.sender, tokenId);
  }

  function payReferrer(address referrer) internal {
    uint256 refAmount = LAND_PRICE.percent(REFERRAL_PERCENT);
    users[referrer].refAmounts += refAmount;

    emit ReferralReceived(referrer, _msgSender(), refAmount);
  }

  function withdrawInterest() public nonReentrant {
    uint256 amount = users[_msgSender()].refAmounts;
    require(amount > 0, "ETH");

    users[_msgSender()].refAmounts = 0;
    _safeTransferETH(_msgSender(), amount);
  }

  function exists(address account) public view returns (bool) {
    return users[account].referrer != address(0);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal override whenNotPaused {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  receive() external payable {}
}
