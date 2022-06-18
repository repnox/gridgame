// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./RegistrationAware.sol";
import "./ERC721Registered.sol";

abstract contract ERC721Stakeable is ERC721Registered {

    mapping(uint256 => bool) stakingLookup;

    function stake(uint256 id) external onlyRegistered {
        _setStake(id, true);
    }

    function unstake(uint256 id) external onlyRegistered {
        _setStake(id, false);
    }

    function isStaked(uint256 id) external view returns (bool) {
        return _isStaked(id);
    }

    function _isStaked(uint256 id) internal view returns (bool) {
        return stakingLookup[id];
    }

    function _setStake(uint256 id, bool staked) internal {
        stakingLookup[id] = staked;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(!_isStaked(tokenId));
        super._beforeTokenTransfer(from, to, tokenId);
    }


}
