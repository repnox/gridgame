pragma solidity ^0.8.0;

import "./extension/RegistrationAware.sol";
import "./interface/PlayerEventCallbacksInterface.sol";
import "./interface/PlayerStakingInterface.sol";
import "./interface/GetPlayerStakingInterface.sol";

contract PlayerEventCallbacks is RegistrationAware, PlayerEventCallbacksInterface {

    constructor(address _applicationRegistry) RegistrationAware(_applicationRegistry) {}

    function beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) external override onlyRegistered {
        require(!_playerStaking().isStaked(tokenId), "Is Staked");
    }

    function beforeMint(
        address to,
        uint256 tokenId
    ) external override onlyRegistered {
        _playerStaking().stake(tokenId);
    }

    function beforeBurn(
        uint256 tokenId
    ) external override onlyRegistered {
        require(!_playerStaking().isStaked(tokenId), "Is Staked");
    }

    function _playerStaking() internal view returns (PlayerStakingInterface) {
        return PlayerStakingInterface(GetPlayerStakingInterface(applicationRegistry).getPlayerStaking());
    }


}
