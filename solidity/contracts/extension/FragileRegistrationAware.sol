// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./RegistrationAware.sol";
import "../ApplicationRegistry.sol";

// Use this base for any component that can be easily replaced by a deployment
// Basically, it's not for NFTs or Tokens.
abstract contract FragileRegistrationAware is RegistrationAware {

    function _applicationRegistry() internal view returns (ApplicationRegistry) {
        return ApplicationRegistry(applicationRegistry);
    }

}