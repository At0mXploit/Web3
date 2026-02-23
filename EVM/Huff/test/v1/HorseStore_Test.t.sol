// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

import {Base_TestV1, IHorseStore} from "./Base_TestV1.t.sol";
import {HorseStore} from "../../src/horseStorev1/HorseStore.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

contract HorseStoreSolidity_Test is Base_TestV1 {
    function setUp() public {
        horseStore = IHorseStore(address(new HorseStore()));
    }
}

contract HorseStoreHuff_Test is Base_TestV1 {
    function setUp() public {
        horseStore = IHorseStore(
            HuffDeployer.deploy("horseStorev1/HorseStore")
        );
    }
}
