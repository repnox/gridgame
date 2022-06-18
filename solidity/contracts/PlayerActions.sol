// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./extension/FragileRegistrationAware.sol";
import "./Stats.sol";
import "./Grid.sol";
import "./MovementController.sol";
import "./opensea/common/meta-transactions/ContentMixin.sol";

contract PlayerActions is FragileRegistrationAware, ContextMixin {

    uint256 initialTravelStat = 1;

    event PlayerCreated(address owner, uint256 id);
    event PlayerMoved(uint256 id, int128 x, int128 y);
    event PlayerUnstaked(uint256 id);
    event PlayerStaked(uint256 id);

    constructor(ApplicationRegistry _applicationRegistry) RegistrationAware(_applicationRegistry) {}

    function createPlayer() external returns (uint256) {
        address mintTo = msg.sender;
        uint256 id = _applicationRegistry().player().mintTo(mintTo);
        _initializePlayer(id);
        emit PlayerCreated(mintTo, id);
        return id;
    }

    function unstakePlayer(uint256 id) external {
        _requireAuthorized(id);
        _requireInPlay(id);
        _applicationRegistry().player().unstake(id);
        _applicationRegistry().movementController().disableMovement(id);
        emit PlayerUnstaked(id);
    }

    function stakePlayer(uint256 id) external {
        _requireAuthorized(id);
        _requireNotInPlay(id);
        _applicationRegistry().player().stake(id);
        _applicationRegistry().movementController().initializeMovement(id);
        emit PlayerStaked(id);
    }

    function movePlayer(uint256 id, int128 x, int128 y) external {
        _requireAuthorized(id);
        _requireInPlay(id);
        MovementController movementController = _applicationRegistry().movementController();
        Stats stats = _applicationRegistry().stats();
        Grid grid = _applicationRegistry().grid();
        if (grid.getGridHash(x, y) == 0) {
            grid.reveal(x, y);
        }
        uint256 travelDistance = movementController.calculateTravelDistance(id, x, y);
        uint256 travelStat = stats.getStat(id, stats.STAT_TRAVEL());
        require(travelDistance <= travelStat, "Too far");
        movementController.setLocation(id, x, y);
        emit PlayerMoved(id, x, y);
    }

    function setInitialTravelStat(uint256 _initialTravelStat) external onlyOwner {
        initialTravelStat = _initialTravelStat;
    }

    function _requireAuthorized(uint256 id) internal view {
        require(_applicationRegistry().player().ownerOf(id) == msgSender(), "Not owner");
    }

    function _requireInPlay(uint256 id) internal view {
        require(_applicationRegistry().player().isStaked(id), "Not staked");
    }

    function _requireNotInPlay(uint256 id) internal view {
        require(!_applicationRegistry().player().isStaked(id), "Staked");
    }

    function _initializePlayer(uint256 id) internal {
        _applicationRegistry().movementController().initializeMovement(id);
        Stats stats = _applicationRegistry().stats();
        stats.setStat(id, stats.STAT_TRAVEL(), initialTravelStat);
    }

}
