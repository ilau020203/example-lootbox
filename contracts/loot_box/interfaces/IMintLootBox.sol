// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IMintLootBox {
    function mint(address to, uint256 id, uint256 value) external;
}
