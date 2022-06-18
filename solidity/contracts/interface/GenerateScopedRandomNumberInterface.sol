// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface GenerateScopedRandomNumberInterface {
    function generateScopedRandomNumber(uint256 scope, bytes memory context) external returns (uint256);
    function generateScopedRandomNumber(address scope, bytes memory context) external returns (uint256);
}
