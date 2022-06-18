// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface MathInterface {
    function abs(int128 x) external pure returns (uint128);
    function sqrt(uint256 y) external pure returns (uint256);
}
