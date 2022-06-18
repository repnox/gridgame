// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IsAccessRegisteredInterface {
    function isAccessRegistered(address _address) external view returns (bool);
}
