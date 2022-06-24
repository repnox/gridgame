// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface PlayerEventCallbacksInterface {

    function beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function beforeMint(
        address to,
        uint256 tokenId
    ) external;

    function beforeBurn(
        uint256 tokenId
    ) external;

}
