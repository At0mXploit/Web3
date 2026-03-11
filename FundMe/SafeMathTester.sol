// SPDX-License-Identifier: MIT

// SafeMath Library

pragma solidity ^0.8.18;

contract SafeMathTester {
    uint8 public bigNumber = 255; // checked overflow and underflow
    // In old versions 255 if you add more it would go 
    // overflow or underflow and SafeMath would prevent it
    // but not in newer version of solidity

    function add() public {
        unchecked {bigNumber = bigNumber + 1;}
        // unchecked keyword wont check for that overflow or underflow problem
        // sometimes this keyword is gas efficient
    }
}
