// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../loot_box/interfaces/IBurnLootBox.sol";
import "../nft_game/interfaces/IMintGame.sol";


contract LootBoxFullRandomOpener is Ownable {
    uint256 constant COMMON = 0;
    uint256 constant RARE = 1;
    uint256 constant LEGENDARY = 2;

    event SetGameNFT(uint256 tier, address NFTGame);
    event OpenCommonLootBox(address caller);
    event OpenRareLootBox(address caller);
    event OpenLegendaryLootBox(address caller);

    struct ArrayOfGames {
        mapping(uint256 => Game) games;
        uint256 count;
    }

    struct Game {
        address NFTGame;
        uint256 countOfMint;
    }

    mapping(uint256 => ArrayOfGames) public tierGames;
    address lootBox;

    constructor(address _lootBox) {
        lootBox = _lootBox;
    }

    function randMod(uint256 _modulus, uint256 salt)
    internal
    returns (uint256)
    {
        return
        uint256(
            keccak256(
                abi.encodePacked(
                    block.difficulty,
                    block.timestamp,
                    msg.sender,
                    salt
                )
            )
        ) % _modulus;
    }

    function setGameNFT(uint256 tier, address NFTGame) external onlyOwner {
        tierGames[tier].games[tierGames[tier].count++].NFTGame = NFTGame;
        emit SetGameNFT(tier, NFTGame);
    }


    function mintRandomGameByTier(uint256 tier, uint256 salt) internal {
        uint256 id = randMod(tierGames[tier].count, salt);
        IMintGame(tierGames[tier].games[id].NFTGame).mint(
            msg.sender,
            tierGames[tier].games[id].countOfMint
        );
    }

    function openCommonLootBox() external {
        IBurnLootBox(lootBox).burn(msg.sender, COMMON, 1);
        mintRandomGameByTier(COMMON, 1);
        if (randMod(10, 2) > 7) {
            mintRandomGameByTier(COMMON, 3);
        } else {
            mintRandomGameByTier(COMMON, 4);
        }
        emit OpenCommonLootBox(msg.sender);
    }

    function openRareLootBox() external {
        IBurnLootBox(lootBox).burn(msg.sender, RARE, 1);
        mintRandomGameByTier(RARE, 1);
        if (randMod(10, 2) > 4) {
            mintRandomGameByTier(RARE, 3);
        } else {
            mintRandomGameByTier(COMMON, 4);
        }
        uint randNumber = randMod(10, 5);
        if (randNumber < 4) {
            mintRandomGameByTier(COMMON, 6);
        } else if (randNumber > 7) {
            mintRandomGameByTier(LEGENDARY, 7);
        }
        else {
            mintRandomGameByTier(RARE, 9);
        }
        emit OpenRareLootBox(msg.sender);
    }

    function openLegendaryLootBox() external {
        IBurnLootBox(lootBox).burn(msg.sender, LEGENDARY, 1);
        mintRandomGameByTier(RARE, 1);
        mintRandomGameByTier(LEGENDARY, 20);
        if (randMod(10, 2) > 5) {
            mintRandomGameByTier(COMMON, 3);
        } else {
            mintRandomGameByTier(RARE, 4);
        }
        uint randNumber = randMod(10, 5);
        if (randNumber < 3) {
            mintRandomGameByTier(COMMON, 6);
        } else if (randNumber > 6) {
            mintRandomGameByTier(LEGENDARY, 7);
        }
        else {
            mintRandomGameByTier(RARE, 9);
        }
        emit OpenLegendaryLootBox(msg.sender);
    }
}
