// SPDX-License-Identifier: UNLICENSED
// License identifier for the contract (required by Solidity compiler)

pragma solidity 0.8.31;
// Specifies the exact Solidity compiler version to use

import {SimpleStorage} from "./SimpleStorage.sol";
// Imports the SimpleStorage contract so this contract can create and interact with it

contract StorageFactory {

    // Array that stores all deployed SimpleStorage contract instances
    SimpleStorage[] public listOfSimpleStorageContracts;

    // This function deploys a NEW SimpleStorage contract
    function createSimpleStorageContract() public {
        // Create a new SimpleStorage contract on the blockchain
        SimpleStorage newSimpleStorageContract = new SimpleStorage();

        // Save the address/reference of the new contract in the array
        listOfSimpleStorageContracts.push(newSimpleStorageContract);
    }

    // This function stores a number in a specific SimpleStorage contract
    function sfStore(uint256 _simpleStorageIndex, uint256 _newSimpleStorageNumber) public {
        // Find the SimpleStorage contract at the given index
        // Then call its store() function to save the new number
        listOfSimpleStorageContracts[_simpleStorageIndex].store(_newSimpleStorageNumber);
    }

    // This function reads the stored number from a specific SimpleStorage contract
    function sfGet(uint256 _simpleStorageIndex) public view returns (uint256) {
        // Call retrieve() on the selected SimpleStorage contract and return the value
        return listOfSimpleStorageContracts[_simpleStorageIndex].retrieve();
    }
}

