pragma solidity ^0.8.0;

import "./extension/RegistrationAware.sol";
import "./interface/PlayerEventCallbacksInterface.sol";
import "./interface/PlayerStakingInterface.sol";

contract PlayerStaking is RegistrationAware, PlayerStakingInterface {

    constructor(address _applicationRegistry) RegistrationAware(_applicationRegistry) {}

    mapping(uint256 => bool) stakingLookup;

    function stake(uint256 id) external override onlyRegistered {
        _setStake(id, true);
    }

    function unstake(uint256 id) external override onlyRegistered {
        _setStake(id, false);
    }

    function isStaked(uint256 id) external override view returns (bool) {
        return _isStaked(id);
    }

    function _isStaked(uint256 id) internal view returns (bool) {
        return stakingLookup[id];
    }

    function _setStake(uint256 id, bool staked) internal {
        stakingLookup[id] = staked;
    }

}
