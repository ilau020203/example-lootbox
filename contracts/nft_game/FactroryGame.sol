// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./NFTGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FactoryGame is  Ownable {
    event DeployGame(address creator,address addressOfGame);

    function deployGame(
        string memory name_,
        string memory symbol_,
        string memory uri_,
        string memory description_,
        uint8 rarity_
    ) external  {
        NFTGame newGame = new NFTGame(name_,symbol_,uri_,description_,rarity_);
        newGame.transferOwnership(msg.sender);
        emit DeployGame(msg.sender,address(newGame));
    }
}