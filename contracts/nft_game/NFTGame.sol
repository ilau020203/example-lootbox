// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTGame is ERC721, Ownable {
    string private uri;
    string public description;
    uint8 public rarity;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory uri_,
        string memory description_,
        uint8 rarity_
    ) ERC721(name_, symbol_) {
        uri = uri_;
        description = description_;
        rarity = rarity_;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _baseURI();
    }


    function _baseURI() internal view virtual override returns (string memory) {
        return uri;
    }

    function mint(address to, uint256 tokenId) external onlyOwner {
        _safeMint(to, tokenId);
    }
}