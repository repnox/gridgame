// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interface/IsAccessRegisteredInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// This base is designed to be future-proof, with extra decoupling with the ApplicationRegistry.
// It's designed to be used by NFTs and Tokens, avoiding re-deployments of code.
abstract contract RegistrationAware is Ownable {

    address internal applicationRegistry;

    constructor(IsAccessRegisteredInterface _applicationRegistry) {
        applicationRegistry = address(_applicationRegistry);
    }

    function setApplicationRegistry(address _applicationRegistry) external onlyOwner {
        applicationRegistry = _applicationRegistry;
    }

    modifier onlyRegistered() {
        require(IsAccessRegisteredInterface(applicationRegistry).isAccessRegistered(msg.sender), "RegistrationAware: Access denied");
        _;
    }


}
