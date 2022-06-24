// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ApplicationRegistry.sol";
import "./interface/IsInBoundsInterface.sol";
import "./interface/GetCommonLibInterface.sol";
import "./interface/EncodeCoordinatesInterface.sol";
import "./interface/GetScopedRandomGeneratorInterface.sol";
import "./interface/GenerateScopedRandomNumberInterface.sol";
import "./interface/MathInterface.sol";
import "./extension/RegistrationAware.sol";

contract Grid is IsInBoundsInterface, RegistrationAware {

    event GridHashRevealed(
        int128 x,
        int128 y,
        uint256 value
    );

    mapping(uint256 => uint256) gridHashes;

    int128 public minX;
    int128 public minY;
    int128 public maxX;
    int128 public maxY;

    constructor(address _applicationRegistry,
                int128 _minX, int128 _minY, int128 _maxX, int128 _maxY
            ) RegistrationAware(_applicationRegistry) {
        minX = _minX;
        minY = _minY;
        maxX = _maxX;
        maxY = _maxY;
        _reveal(0,0);
    }

    function getGridHash(int128 x, int128 y) external view returns (uint256) {
        return _getGridHash(x, y);
    }

    function getBounds() external view returns (int128, int128, int128, int128) {
        return (minX, minY, maxX, maxY);
    }

    function setBounds(int128 _minX, int128 _minY, int128 _maxX, int128 _maxY) external onlyRegistered {
        minX = _minX;
        minY = _minY;
        maxX = _maxX;
        maxY = _maxY;
    }

    function setHash(int128 x, int128 y, uint256 hash) external onlyRegistered {
        uint256 key = _encodeCoordinates(x, y);
        gridHashes[key] = hash;
        emit GridHashRevealed(x, y, hash);
    }

    function reveal(int128 x, int128 y) external onlyRegistered returns (uint256) {
        return _reveal(x, y);
    }

    function isRevealed(int128 x, int128 y) external view returns (bool) {
        return _getGridHash(x,y) > 0;
    }

    function isInBounds(int128 x, int128 y) external override view returns (bool) {
        return _isInBounds(x, y);
    }

    function _isInBounds(int128 x, int128 y) internal view returns (bool) {
        return minX <= x && x <= maxX && minY <= y && y <= maxY;
    }

    function _reveal(int128 x, int128 y) internal returns (uint256) {
        require(_isInBounds(x, y), "Grid: Coord not in range");
        uint256 key = _encodeCoordinates(x, y);
        require(gridHashes[key] == 0x0, "Grid: already revealed");
        uint256 hash = _generateHash(key);
        gridHashes[key] = hash;
        emit GridHashRevealed(x, y, hash);
        return hash;
    }

    function _generateHash(uint256 key) internal returns (uint256) {
        if (key == 0) {
            return uint256(keccak256(abi.encodePacked(address(this))));
        } else {
            return _generateRandomNumber(abi.encodePacked(key));
        }
    }

    function _getGridHash(int128 x, int128 y) internal view returns (uint256) {
        return gridHashes[_encodeCoordinates(x, y)];
    }

    function _commonLib() internal view returns (address) {
        return GetCommonLibInterface(applicationRegistry).getCommonLib();
    }

    function _encodeCoordinates(int128 x, int128 y) internal view returns (uint256) {
        return EncodeCoordinatesInterface(_commonLib()).encodeCoordinates(x, y);
    }

    function _scopedRandomGenerator() internal view returns (address) {
        return GetScopedRandomGeneratorInterface(applicationRegistry).getScopedRandomGenerator();
    }

    function _generateRandomNumber(bytes memory context) internal returns (uint256) {
        return GenerateScopedRandomNumberInterface(_scopedRandomGenerator()).generateScopedRandomNumber(tx.origin, context);
    }


}
