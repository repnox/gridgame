// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ApplicationRegistry.sol";
import "./extension/ERC721Registered.sol";
import "./interface/GetScopedRandomGeneratorInterface.sol";
import "./interface/GetPlayerEventCallbacksInterface.sol";
import "./interface/GenerateScopedRandomNumberInterface.sol";
import "./interface/PlayerEventCallbacksInterface.sol";

contract Player is ERC721Registered {

    constructor(address _applicationRegistry) ERC721Registered(_applicationRegistry, "Grid Game Player", "GGP") {
    }

    function mintTo(address _to) external onlyRegistered returns (uint256) {
        uint256 id = _generatePlayerId(_to);
        _playerEventCallbacks().beforeMint(_to, id);
        _mint(_to, id);
        return id;
    }

    function burn(uint256 id) external onlyRegistered {
        _playerEventCallbacks().beforeBurn(id);
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

    function _playerEventCallbacks() internal view returns (PlayerEventCallbacksInterface) {
        return PlayerEventCallbacksInterface(GetPlayerEventCallbacksInterface(applicationRegistry).getPlayerEventCallbacks());
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        _playerEventCallbacks().beforeTokenTransfer(from, to, tokenId);
        super._beforeTokenTransfer(from, to, tokenId);
    }

}
