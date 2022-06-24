// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ApplicationRegistry.sol";
import "./extension/ERC721PlayerOwnable.sol";
import "./interface/GetScopedRandomGeneratorInterface.sol";
import "./interface/GenerateScopedRandomNumberInterface.sol";
import "./interface/GetPlayerInterface.sol";

contract Item is ERC721PlayerOwnable {

    constructor(address _applicationRegistry) ERC721Registered(_applicationRegistry, "Grid Game Item", "GGI") {
    }

    function getItemType(uint256 id) external pure returns (uint256) {
        return (id >> 128) & 0xFF;
    }

    function getItemHash(uint256 id) external pure returns (uint256) {
        return id & type(uint128).max;
    }

    function mintTo(address to, uint256 itemType, uint256 playerId) external onlyRegistered returns (uint256) {
        return _mintTo(to, itemType, playerId);
    }

    function burn(uint256 id) external onlyRegistered {
        _burn(id);
    }

    function baseTokenURI() override public pure returns (string memory) {
        return "";
    }

    function tokenURI(uint256) override public pure returns (string memory) {
        return baseTokenURI();
    }

    function _mintTo(address to, uint256 itemType, uint256 playerId) internal returns (uint256) {
        require(to != address(0), "Mint to burn");
        require(_playerOwnerOf(playerId) == to, "Player not owned");
        uint256 id = _generateScopedRandomNumber(playerId, abi.encodePacked(to));
        // Mask the rightmost bits
        id = id & type(uint128).max;
        // Add item type to leftmost bits
        id = id | (itemType << 128);
        _mint(to, id);
        _setPlayerOwnership(id, playerId);
        return id;
    }

    function _randomGenerator() internal view returns (address) {
        return GetScopedRandomGeneratorInterface(applicationRegistry).getScopedRandomGenerator();
    }

    function _player() internal view returns (address) {
        return GetPlayerInterface(applicationRegistry).getPlayer();
    }

    function _playerOwnerOf(uint256 token) internal view returns (address) {
        return IERC721(_player()).ownerOf(token);
    }

    function _generateScopedRandomNumber(uint256 player, bytes memory context) internal returns (uint256) {
        return GenerateScopedRandomNumberInterface(_randomGenerator()).generateScopedRandomNumber(player, context);
    }

}
