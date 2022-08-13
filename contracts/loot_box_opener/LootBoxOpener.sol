// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../loot_box/interfaces/IBurnLootBox.sol";
import "../nft_game/interfaces/IMintGame.sol";

contract LootBoxOpener is Ownable {
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
    view
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

    function arrayNotHaveNumber(uint256[] memory array, uint number) internal pure returns (bool){
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == number) {
                return false;
            }
        }
        return true;
    }

    function mintRandomGameByTier(uint256 tier, uint256 salt, uint256[] memory received) internal returns(uint256[] memory) {

        uint256 id = randMod(tierGames[tier].count, salt);
        while (!arrayNotHaveNumber(received, id)) {
            salt++;
            id = randMod(tierGames[tier].count, salt);
        }
        uint256[] memory newReceived = new uint256[](received.length + 1);
        for (uint i = 0; i < received.length; i++) {
            newReceived[i] = received[i];
        }
        newReceived[received.length] = id;
        IMintGame(tierGames[tier].games[id].NFTGame).mint(
            msg.sender,
            tierGames[tier].games[id].countOfMint
        );
        return newReceived;
    }

    function openCommonLootBox() external {
        IBurnLootBox(lootBox).burn(msg.sender, COMMON, 1);
        uint256[] memory received;
        received = mintRandomGameByTier(COMMON, 1, received);
        if (randMod(10, 2) > 7) {
            received = mintRandomGameByTier(COMMON, 3, received);
        } else {
            received = mintRandomGameByTier(COMMON, 4, received);
        }
        emit OpenCommonLootBox(msg.sender);
    }

    function openRareLootBox() external {
        IBurnLootBox(lootBox).burn(msg.sender, RARE, 1);
        uint256[] memory received;
        received = mintRandomGameByTier(RARE, 1, received);
        if (randMod(10, 2) > 4) {
            received = mintRandomGameByTier(RARE, 3, received);
        } else {
            received = mintRandomGameByTier(COMMON, 4, received);
        }
        uint randNumber = randMod(10, 5);
        if (randNumber < 4) {
            received = mintRandomGameByTier(COMMON, 6, received);
        } else if (randNumber > 7) {
            received = mintRandomGameByTier(LEGENDARY, 7, received);
        }
        else {
            received = mintRandomGameByTier(RARE, 9, received);
        }
        emit OpenRareLootBox(msg.sender);
    }

    function openLegendaryLootBox() external {
        IBurnLootBox(lootBox).burn(msg.sender, LEGENDARY, 1);
        uint256[] memory received;
        received = mintRandomGameByTier(RARE, 1, received);
        received = mintRandomGameByTier(LEGENDARY, 20, received);
        if (randMod(10, 2) > 5) {
            received = mintRandomGameByTier(COMMON, 3, received);
        } else {
            received = mintRandomGameByTier(RARE, 4, received);
        }
        uint randNumber = randMod(10, 5);
        if (randNumber < 3) {
            received = mintRandomGameByTier(COMMON, 6, received);
        } else if (randNumber > 6) {
            received = mintRandomGameByTier(LEGENDARY, 7, received);
        }
        else {
            received = mintRandomGameByTier(RARE, 9, received);
        }
        emit OpenLegendaryLootBox(msg.sender);
    }
}
