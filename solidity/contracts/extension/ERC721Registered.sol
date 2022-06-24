// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../opensea/common/meta-transactions/ContentMixin.sol";
import "../opensea/common/meta-transactions/NativeMetaTransaction.sol";
import "./RegistrationAware.sol";
import "./ERC721EnumerableExtended.sol";

abstract contract ERC721Registered is ContextMixin, ERC721EnumerableExtended, NativeMetaTransaction, RegistrationAware {
    using SafeMath for uint256;

    constructor(
        address _applicationRegistry,
        string memory _name,
        string memory _symbol
    ) RegistrationAware(_applicationRegistry) ERC721(_name, _symbol) {
        _initializeEIP712(_name);
    }

    /**
     * @dev Mints a token to an address with a tokenURI.
     * @param _to address of the future owner of the token
     */
    function mintTo(address _to, uint256 tokenId) public onlyRegistered {
        _mint(_to, tokenId);
    }

    function baseTokenURI() virtual public pure returns (string memory);

    /**
     * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function isApprovedForAll(address owner, address operator)
    override
    public
    view
    returns (bool)
    {
        return super.isApprovedForAll(owner, operator);
    }

    /**
     * This is used instead of msg.sender as transactions won't be sent by the original token owner, but by OpenSea.
     */
    function _msgSender()
    internal
    override
    view
    returns (address sender)
    {
        return ContextMixin.msgSender();
    }
}
