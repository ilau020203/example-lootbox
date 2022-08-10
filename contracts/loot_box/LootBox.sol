// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LootBox is ERC1155Burnable, Ownable {
    mapping(uint256 => string) public names;
    mapping(uint256 => uint256) private _totalSupply;
    mapping(uint256 => string) private tokenUri;

    /**
     * @param uri_ uri string
     */
    constructor(string memory uri_) ERC1155(uri_) {}

    /**
     * @param id id of token
     * @return uri of token id
     */
    function uri(uint256 id) public view override returns (string memory) {
        return string.concat(ERC1155.uri(id), tokenUri[id]);
    }

    /**
     * @param tokenId id of token
     * @param _tokenUri uri for token id
     */
    function addTokenId(
        uint256 tokenId,
        string memory name,
        string memory _tokenUri
    ) external onlyOwner {
        tokenUri[tokenId] = _tokenUri;
        names[tokenId] = name;
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     */
    function mint(
        address to,
        uint256 tokenId,
        uint256 amount
    ) external onlyOwner {
        _mint(to, tokenId, amount, "");
    }

    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) public view virtual returns (bool) {
        return _totalSupply[id] > 0;
    }

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] -= amounts[i];
            }
        }
    }
}
