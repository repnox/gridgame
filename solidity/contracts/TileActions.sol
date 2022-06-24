// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./extension/FragileRegistrationAware.sol";
import "./interface/PlayerStakingInterface.sol";
import "./MovementController.sol";
import "./Item.sol";
import "./opensea/common/meta-transactions/ContentMixin.sol";

contract TileActions is FragileRegistrationAware, ContextMixin {

    uint256 public constant ACTION_FIGHT_PVP = 0x0;
    uint256 public constant ACTION_FIGHT_PVE = 0x1;
    uint256 public constant ACTION_LOOTBOX_GEN = 0x2;
    uint256 public constant ACTION_MCGUFFIN_GEN = 0x3;
    uint256 public constant ACTION_FETCH_QUEST = 0x4;
    uint256 public constant ACTION_MINT_COIN = 0x5;
    uint256 public constant ACTION_LOOTBOX_REDEMPTION = 0x6;

    uint256 public constant ITEM_TYPE_LOOTBOX = 0x0;
    uint256 public constant ITEM_TYPE_MCGUFFIN = 0x1;

    event LootboxMinted(address owner, uint256 playerId, uint256 lootboxType, uint256 itemId);
    event McguffinMinted(address owner, uint256 playerId, uint256 mcguffinType, uint256 itemId);
    event FetchQuestComplete(address owner, uint256 playerId, uint256 itemId, uint256 rewardType, uint256 rewardId);

    constructor(address _applicationRegistry) RegistrationAware(_applicationRegistry) {}

    function mintLootbox(uint256 playerId) external {
        _requireAuthorized(playerId);
        _requireInPlay(playerId);
        MovementController.Coord memory coord = _applicationRegistry().movementController().getLocation(playerId);
        require(_isActionAvailable(coord.x, coord.y, ACTION_LOOTBOX_GEN), "Action not available");
        address msgSender = msgSender();
        uint256 itemId = _applicationRegistry().item().mintTo(msgSender, ITEM_TYPE_LOOTBOX, playerId);
        emit LootboxMinted(msgSender, playerId, 0, itemId);
    }

    function mintMcguffin(uint256 playerId) external {
        _requireAuthorized(playerId);
        _requireInPlay(playerId);
        MovementController.Coord memory coord = _applicationRegistry().movementController().getLocation(playerId);
        require(_isActionAvailable(coord.x, coord.y, ACTION_MCGUFFIN_GEN), "Action not available");
        uint256 gridHash = _applicationRegistry().grid().getGridHash(coord.x, coord.y);
        uint256 mcguffinType = _getGridData1(gridHash);
        address msgSender = msgSender();
        uint256 itemType = (mcguffinType << 16) | ITEM_TYPE_MCGUFFIN;
        uint256 itemId = _applicationRegistry().item().mintTo(msgSender, itemType, playerId);
        emit McguffinMinted(msgSender, playerId, mcguffinType, itemId);
    }

    function completeFetchQuest(uint256 playerId, uint256 itemId) external {
        _requireAuthorized(playerId);
        _requireInPlay(playerId);
        _requirePlayerOwned(playerId, itemId);
        MovementController.Coord memory coord = _applicationRegistry().movementController().getLocation(playerId);
        require(_isActionAvailable(coord.x, coord.y, ACTION_FETCH_QUEST), "Action not available");
        uint256 gridHash = _applicationRegistry().grid().getGridHash(coord.x, coord.y);
        require(_getGridData1(gridHash) == _getItemData1(itemId), "Wrong item type");
        uint256 lootboxType = _getGridData2(gridHash);
        uint256 itemType = (lootboxType << 16) | ITEM_TYPE_LOOTBOX;
        _applicationRegistry().item().burn(itemId);
        address msgSender = msgSender();
        uint256 lootboxId = _applicationRegistry().item().mintTo(msgSender, itemType, playerId);
        emit FetchQuestComplete(msgSender, playerId, itemId, lootboxType, lootboxId);
    }

    function getMcguffinType(int128 x, int128 y) external view returns (uint256) {
        uint256 gridHash = _applicationRegistry().grid().getGridHash(x, y);
        return _getGridData1(gridHash);
    }

    function isActionAvailable(int128 x, int128 y, uint256 action) external view returns (bool) {
        return _isActionAvailable(x, y, action);
    }

    function _getItemData1(uint256 itemId) internal pure returns (uint256) {
        return (itemId >> 16) & 0xFF;
    }

    function _getGridData1(uint256 gridHash) internal pure returns (uint256) {
        uint256 gridData = (gridHash >> 16) & 0xF;
        return gridData;
    }

    function _getGridData2(uint256 gridHash) internal pure returns (uint256) {
        uint256 gridData = (gridHash >> 32) & 0xF;
        return gridData;
    }

    function _isActionAvailable(int128 x, int128 y, uint256 action) internal view returns (bool) {
        uint256 gridHash = _applicationRegistry().grid().getGridHash(x,y);
        require(gridHash != 0, "Undiscovered");
        return (gridHash & 0xF) == action;
    }

    function _requireAuthorized(uint256 id) internal view {
        require(_applicationRegistry().player().ownerOf(id) == msgSender(), "Not owner");
    }

    function _requireInPlay(uint256 id) internal view {
        require(_playerStaking().isStaked(id), "Not staked");
    }

    function _requirePlayerOwned(uint256 playerId, uint256 itemId) internal view {
        require(_applicationRegistry().item().getPlayerOwner(itemId) == playerId, "Not player owned");
    }

    function _playerStaking() internal view returns (PlayerStakingInterface) {
        return PlayerStakingInterface(_applicationRegistry().playerStaking());
    }

}
