// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interface/GetCommonLibInterface.sol";
import "./interface/GetGridInterface.sol";
import "./interface/EncodeCoordinatesInterface.sol";
import "./interface/MathInterface.sol";
import "./interface/IsInBoundsInterface.sol";
import "./extension/RegistrationAware.sol";
import "./ApplicationRegistry.sol";
import "./CommonLib.sol";

contract MovementController is RegistrationAware {

    struct Coord {
        int128 x;
        int128 y;
        bool exists;
    }

    int128 startX = 0;
    int128 startY = 0;

    mapping(uint256 => Coord) coordsLookup;

    mapping(uint256 => uint256) tokenIndex;
    mapping(uint256 => uint256) reverseLookupCount;
    mapping(uint256 => mapping(uint256 => uint256)) reverseLookup;

    constructor(address _applicationRegistry) RegistrationAware(_applicationRegistry) {}

    function getTokensAtCoords(int128 x, int128 y) external view returns (uint256[] memory) {
        uint256 encodedCoords = _encodeCoordinates(x,y);
        uint256 numTokens = reverseLookupCount[encodedCoords];
        uint256[] memory tokens = new uint256[](numTokens);
        for (uint256 i=0; i<numTokens; i++) {
            tokens[i] = reverseLookup[encodedCoords][i];
        }
        return tokens;
    }

    function calculateTravelDistance(uint256 id, int128 toX, int128 toY) external view returns (uint256) {
        Coord memory location = _getLocation(id);
        uint256 dx = uint256(_abs(toX - location.x));
        uint256 dy = uint256(_abs(toY - location.y));
        uint256 distanceSq = dx*dx + dy*dy;
        return _sqrt(distanceSq);
    }

    function getLocation(uint256 token) external view returns (Coord memory) {
        return _getLocation(token);
    }

    function _getLocation(uint256 token) internal view returns (Coord memory) {
        return coordsLookup[token];
    }

    function initializeMovement(uint256 id) external onlyRegistered {
        _setLocation(id, startX, startY);
    }

    function disableMovement(uint256 id) external onlyRegistered {
        Coord memory currentCoord = coordsLookup[id];
        uint256 encodedCoords = _encodeCoordinates(currentCoord.x, currentCoord.y);
        _clearTokenLocation(id, encodedCoords);
    }

    function setStart(int128 x, int128 y) external onlyRegistered {
        startX = x;
        startY = y;
    }

    function setLocation(uint256 token, int128 x, int128 y) external onlyRegistered {
        _setLocation(token, x, y);
    }

    function _setLocation(uint256 token, int128 x, int128 y) internal {
        require(_isInBounds(x, y), "Not in bounds");
        Coord memory currentCoord = coordsLookup[token];
        uint256 encodedCurrentCoords = _encodeCoordinates(currentCoord.x, currentCoord.y);
        if (currentCoord.exists) {
            _clearTokenLocation(token, encodedCurrentCoords);
        }
        uint256 encodedNewCoords = _encodeCoordinates(x, y);
        uint256 index = reverseLookupCount[encodedNewCoords];
        tokenIndex[token] = index;
        coordsLookup[token] = Coord(x, y, true);

        reverseLookupCount[encodedNewCoords] = index + 1;
        reverseLookup[encodedNewCoords][index] = token;
    }

    function _clearTokenLocation(uint256 token, uint256 encodedCoords) internal {
        uint256 index = tokenIndex[token];
        delete tokenIndex[token];
        delete coordsLookup[token];
        uint256 count = reverseLookupCount[encodedCoords];
        reverseLookupCount[encodedCoords] = count - 1;
        if (index != count-1) {
            reverseLookup[encodedCoords][index] = reverseLookup[encodedCoords][count-1];
        }
        delete reverseLookup[encodedCoords][count-1];
    }


    function _commonLib() internal view returns (address) {
        return GetCommonLibInterface(applicationRegistry).getCommonLib();
    }

    function _encodeCoordinates(int128 x, int128 y) internal view returns (uint256) {
        return EncodeCoordinatesInterface(_commonLib()).encodeCoordinates(x, y);
    }

    function _abs(int128 x) internal view returns (uint128) {
        return MathInterface(_commonLib()).abs(x);
    }

    function _sqrt(uint256 x) internal view returns (uint256) {
        return MathInterface(_commonLib()).sqrt(x);
    }

    function _grid() internal view returns (address) {
        return GetGridInterface(applicationRegistry).getGrid();
    }

    function _isInBounds(int128 x, int128 y) internal view returns (bool) {
        return IsInBoundsInterface(_grid()).isInBounds(x, y);
    }
}
