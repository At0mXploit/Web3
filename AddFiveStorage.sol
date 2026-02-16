// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.31;

import {SimpleStorage} from "./SimpleStorage.sol";

// is will inherit all properties from SimpleStorage function to AddFiveStorage
contract AddFiveStorage is SimpleStorage {

    // Use override keyword if you want to overwrite certain function from function you inherited
    function store(uint256 _newNumber) public override {
            myfavoriteNumber = _newNumber + 5;
    }
}

// new keyword = It tells the compiler that a new contract instance is intended to be deployed after compilation.
