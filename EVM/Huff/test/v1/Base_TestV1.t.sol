// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";

interface IHorseStore {
    function updateHorseNumber(uint256 newNumberOfHorses) external;
    function readNumberOfHorses() external view returns (uint256);
}

abstract contract Base_TestV1 is Test {
    IHorseStore public horseStore;

    function test_readDefaultIsZero() public view {
        assertEq(horseStore.readNumberOfHorses(), 0);
    }

    function test_updateAndRead() public {
        horseStore.updateHorseNumber(42);
        assertEq(horseStore.readNumberOfHorses(), 42);
    }

    function testFuzz_updateAndRead(uint256 n) public {
        horseStore.updateHorseNumber(n);
        assertEq(horseStore.readNumberOfHorses(), n);
    }
}
