// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./extension/FragileRegistrationAware.sol";
import "./ApplicationRegistry.sol";
import "./MovementController.sol";

contract GameView is FragileRegistrationAware {

    struct PlayerLocation {
        uint256 id;
        int128 x;
        int128 y;
        bool staked;
    }

    constructor(ApplicationRegistry _applicationRegistry) RegistrationAware(_applicationRegistry) {}

    function getAllPlayerLocations() external onlyRegistered view returns (PlayerLocation[] memory) {
        uint256[] memory playerIds = _applicationRegistry().player().getAllTokens();
        PlayerLocation[] memory playerLocations = new PlayerLocation[](playerIds.length);
        for (uint256 i=0; i<playerIds.length; i++) {
            uint256 playerId = playerIds[i];
            MovementController.Coord memory coord = _applicationRegistry().movementController().getLocation(playerId);
            bool staked = _applicationRegistry().player().isStaked(playerId);
            playerLocations[i] = PlayerLocation(playerId, coord.x, coord.y, staked);
        }
        return playerLocations;
    }

}
