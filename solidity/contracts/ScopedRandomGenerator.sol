// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../installed_contracts/bytes/contracts/BytesLib.sol";
import "./interface/GenerateScopedRandomNumberInterface.sol";
import "./extension/RegistrationAware.sol";

contract ScopedRandomGenerator is GenerateScopedRandomNumberInterface, RegistrationAware {
    using BytesLib for bytes;

    event HashGenerated(
        uint256 value
    );

    mapping(uint256 => uint256) internal scopeState;

    constructor(address _applicationRegistry) RegistrationAware(_applicationRegistry) {}

    function peek(uint256 scope) external view returns (uint256) {
        return _getCurrentState(scope);
    }

    function generateScopedRandomNumber(uint256 scope, bytes memory context) external override onlyRegistered returns (uint256) {
        return _next(scope, context);
    }

    function generateScopedRandomNumber(address scope, bytes memory context) external override onlyRegistered returns (uint256) {
        return _next(uint256(uint160(scope)), context);
    }

    function _next(uint256 scope, bytes memory context) internal returns (uint256) {
        uint256 current = _getCurrentState(scope);
        scopeState[scope] = uint256(keccak256(
                abi.encodePacked(current, msg.sender).concat(context)
            ));
        return current;
    }

    function _getCurrentState(uint256 scope) internal view returns (uint256) {
        if (scopeState[scope] == 0) {
            return uint256(keccak256(abi.encodePacked(scope)));
        }
        return scopeState[scope];
    }

}