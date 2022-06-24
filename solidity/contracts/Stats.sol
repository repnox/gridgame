// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./extension/RegistrationAware.sol";
import "./ApplicationRegistry.sol";

contract Stats is RegistrationAware {

    uint256 public constant STAT_TRAVEL = 0x1;

    mapping(uint256 => mapping(uint256 => uint256)) tokenStatValues;

    constructor(address _applicationRegistry) RegistrationAware(_applicationRegistry) {}

    function setStat(uint256 token, uint256 stat, uint256 value) external onlyRegistered {
        tokenStatValues[token][stat] = value;
    }

    function getStat(uint256 token, uint256 stat) external view returns (uint256) {
        return tokenStatValues[token][stat];
    }

}
