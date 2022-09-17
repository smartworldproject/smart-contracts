// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SmartLand is ERC721Enumerable, Ownable, Pausable {
  using Strings for uint256;

  string baseURI = "ipfs://bafybeihzeuwnt5ltbzfxl7yy2azy2e6ocnxqvwtjbpo734ngqi7olce72q/";
  string public baseExtension = ".json";
  uint256 public cost = 1 wei;
  uint256 public maxSupply = 100;

  constructor() ERC721("SmartLand", "SmartLand") {}

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // public
  function mint(uint256 tokenId) public payable whenNotPaused {
    require(tokenId < maxSupply && !_exists(tokenId), "Not Available");
    require(totalSupply() <= maxSupply);
    require(msg.value >= cost);

    _safeMint(msg.sender, tokenId);
  }

  function mintBatch(uint256[] memory tokenIds) public payable whenNotPaused {
    uint256 length = tokenIds.length;
    require(totalSupply() + length <= maxSupply, "To much token");
    require(msg.value >= cost * length, "Not enough Value");

    for (uint256 i; i < length; i++) {
      uint256 tokenId = tokenIds[i];
      require(tokenId < maxSupply && !_exists(tokenId), "Not Available");

      _safeMint(msg.sender, tokenId);
    }
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    string memory currentBaseURI = _baseURI();
    return string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension));
  }

  //only owner
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function withdraw() public payable onlyOwner {
    (bool success, ) = payable(owner()).call{value: address(this).balance}("");
    require(success);
  }
}
