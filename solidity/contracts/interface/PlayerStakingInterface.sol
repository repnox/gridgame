// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface PlayerStakingInterface {

    function stake(uint256 id) external;

    function unstake(uint256 id) external;

    function isStaked(uint256 id) external view returns (bool);

}
