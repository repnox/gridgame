// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./RegistrationAware.sol";
import "./ERC721Registered.sol";

abstract contract ERC721PlayerOwnable is ERC721Registered {

    // Token ID -> Player ID
    mapping(uint256 => uint256) private playerOwnership;

    // Player ID -> Number of Items
    mapping(uint256 => uint256) private playerItemCount;

    // Token ID -> Item Ownership Index
    mapping(uint256 => uint256) private playerOwnershipItemIndex;

    // Player ID -> Index -> Token ID
    mapping(uint256 => mapping(uint256 => uint256)) private itemOwnership;

    function renouncePlayerOwnership(uint256 tokenId) external onlyRegistered {
        _renounceOwnership(tokenId);
    }

    function setPlayerOwnership(uint256 tokenId, uint256 playerId) external onlyRegistered {
        _setPlayerOwnership(tokenId, playerId);
    }

    function getPlayerOwner(uint256 tokenId) external view returns (uint256) {
        return _getOwner(tokenId);
    }

    function isPlayerOwned(uint256 tokenId) external view returns (bool) {
        return _isPlayerOwned(tokenId);
    }

    function getTokenOfPlayerByIndex(uint256 playerId, uint256 index) external view returns (uint256) {
        return _getTokenOfPlayerByIndex(playerId, index);
    }

    function getPlayerItemCount(uint256 playerId) external view returns (uint256) {
        return _getPlayerItemCount(playerId);
    }

    function _getPlayerItemCount(uint256 playerId) internal view returns (uint256) {
        return playerItemCount[playerId];
    }

    function _getTokenOfPlayerByIndex(uint256 playerId, uint256 index) internal view returns (uint256) {
        require(0 <= index && index < playerItemCount[playerId], "Index out of bounds");
        return itemOwnership[playerId][index];
    }

    function _setPlayerOwnership(uint256 tokenId, uint256 playerId) internal {
        require(_getOwner(tokenId) != playerId, "Already owned");
        if (_isPlayerOwned(tokenId)) {
            _renounceOwnership(tokenId);
        }
        _addOwnership(tokenId, playerId);
    }

    function _getOwner(uint256 tokenId) internal view returns (uint256) {
        return playerOwnership[tokenId];
    }

    function _isPlayerOwned(uint256 tokenId) internal view returns (bool) {
        return playerOwnership[tokenId] != 0;
    }

    function _addOwnership(uint256 tokenId, uint256 playerId) internal {
        playerOwnership[tokenId] = playerId;
        uint256 index = playerItemCount[playerId];
        playerItemCount[playerId] = index + 1;
        playerOwnershipItemIndex[tokenId] = index;
        itemOwnership[playerId][index] = tokenId;
    }

    function _renounceOwnership(uint256 tokenId) internal {
        uint256 oldPlayerId = playerOwnership[tokenId];
        uint256 oldNumItems = playerItemCount[oldPlayerId];
        uint256 oldPlayerOwnershipIndex = playerOwnershipItemIndex[tokenId];
        delete playerOwnership[tokenId];
        playerItemCount[oldPlayerId] = oldNumItems - 1;
        delete playerOwnershipItemIndex[tokenId];
        itemOwnership[oldPlayerId][oldPlayerOwnershipIndex] = itemOwnership[oldPlayerId][oldNumItems-1];
        delete itemOwnership[oldPlayerId][oldNumItems-1];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(!_isPlayerOwned(tokenId), "Player owned");
        super._beforeTokenTransfer(from, to, tokenId);
    }


}
