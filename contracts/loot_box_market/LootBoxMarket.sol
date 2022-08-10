// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../loot_box/interfaces/IMintLootBox.sol";

contract LootBoxMarket is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public token;
    IMintLootBox public lootBox;
    mapping(uint256 => uint256) public prices;
    event AddNFTLootBox(uint256 tokenID, uint256 price);
    event WithdrowAllTokens(address to, uint256 amount);
    event BuyToken(address lootBox, uint256 tokenId, uint256 price);

    /**
     * @param _token address of token for which ERC1155 is being sold
     * @param _lootBox address of ERC1155 
     */
    constructor(address _token, address _lootBox) {
        token = IERC20(_token);
        lootBox = IMintLootBox(_lootBox);
    }
    
    /**
     * @dev Set price of token 
     * @param id id of token
     * @param price price of one id's token
     */
    function setLootBoxPrice(uint256 id, uint256 price) external onlyOwner {
        require(price > 0, "LootBoxMarket:Price must be more than zero");
        prices[id] = price;
        emit AddNFTLootBox(id, price);
    }

    /**
     * @dev Transfer all token(ERC20) from this contract to owner
     */
    function withdrowAllTokens() external onlyOwner {
        token.safeTransfer(owner(), token.balanceOf(address(this)));
        emit WithdrowAllTokens(owner(), token.balanceOf(address(this)));
    }

    /**
     * @dev Mint token to the msg.sender for a price this token
     */
    function buyToken(uint256 id, uint256 amount) external {
        require(prices[id] > 0, "LootBoxMarket:LootBox is not for sale");
        token.safeTransferFrom(msg.sender, address(this), amount * prices[id]);
        lootBox.mint(msg.sender, id, amount);
        emit BuyToken(msg.sender, id, amount);
    }
}
