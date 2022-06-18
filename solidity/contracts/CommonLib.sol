// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../installed_contracts/bytes/contracts/BytesLib.sol";
import "./interface/EncodeCoordinatesInterface.sol";
import "./interface/MathInterface.sol";

contract CommonLib is EncodeCoordinatesInterface, MathInterface {
    using BytesLib for bytes;

    function encodeCoordinates(int128 x, int128 y) public override pure returns (uint256) {
        return abi.encodePacked(x, y).toUint256(0x0);
    }

    function abs(int128 x) public override pure returns (uint128) {
        return uint128(x >= 0 ? x : -x);
    }

    function sqrt(uint256 y) public override pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        } else {
            z = 0;
        }
    }

}
