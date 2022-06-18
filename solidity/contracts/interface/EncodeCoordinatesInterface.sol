// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface EncodeCoordinatesInterface {
    function encodeCoordinates(int128 x, int128 y) external pure returns (uint256);
}
