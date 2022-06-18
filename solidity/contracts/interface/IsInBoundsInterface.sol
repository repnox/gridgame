// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IsInBoundsInterface {
    function isInBounds(int128 x, int128 y) external view returns (bool);
}
