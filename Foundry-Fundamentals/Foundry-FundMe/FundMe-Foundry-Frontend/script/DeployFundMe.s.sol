// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol"; // Script base contract from foundry
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        vm.startBroadcast(); // everything after this gets sent as a real transaction
        FundMe fundMe = new FundMe();
        vm.stopBroadcast(); // stop broadcasting transactions
        return fundMe;
    }
}
