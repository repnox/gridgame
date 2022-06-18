// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ApplicationRegistry.sol";
import "./extension/ERC721Stakeable.sol";
import "./interface/GetScopedRandomGeneratorInterface.sol";
import "./interface/GenerateScopedRandomNumberInterface.sol";

contract Player is ERC721Stakeable {

    constructor(ApplicationRegistry _applicationRegistry) ERC721Registered(_applicationRegistry, "Grid Game Player", "GGP") {
    }

    function mintTo(address _to) external onlyRegistered returns (uint256) {
        uint256 id = _generatePlayerId(_to);
        _mint(_to, id);
        _setStake(id, true);
        return id;
    }

    function burn(uint256 id) external onlyRegistered {
        _burn(id);
    }

    function baseTokenURI() override public pure returns (string memory) {
        return "";
    }

    function tokenURI(uint256) override public pure returns (string memory) {
        return baseTokenURI();
    }

    function _randomGenerator() internal view returns (address) {
        return GetScopedRandomGeneratorInterface(applicationRegistry).getScopedRandomGenerator();
    }

    function _generatePlayerId(address to) internal returns (uint256) {
        bytes memory context = abi.encodePacked(to);
        return GenerateScopedRandomNumberInterface(_randomGenerator()).generateScopedRandomNumber(to, context);
    }

}
