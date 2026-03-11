// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user"); // creates a fake wallet address labeled "user"
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe(); // 'new' deploys a fresh contract instance
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // gives USER fake ETH to work with
    }

    modifier funded() {
        vm.prank(USER); // makes the very next call come from USER instead of this test contract
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function test_MinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18); // assertEq checks two values are equal, fails test if not
    }

    function test_OwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function test_FundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // tells foundry: the next call MUST revert, otherwise fail the test
        fundMe.fund{value: 0}();
    }

    function test_FundUpdatesFundersArray() public funded {
        assertEq(fundMe.funders(0), USER);
    }

    function test_FundUpdatesAddressToAmountFunded() public funded {
        assertEq(fundMe.addressToAmountFunded(USER), SEND_VALUE);
    }

    function test_MultipleFunders() public {
        uint160 numberOfFunders = 10;

        for (uint160 i = 1; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE); // hoax = vm.prank + vm.deal combined, one liner to impersonate and fund
            fundMe.fund{value: SEND_VALUE}();
        }

        assertEq(address(fundMe).balance, SEND_VALUE * (numberOfFunders - 1));
    }

    function test_OnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function test_WithdrawWithSingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.i_owner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.i_owner());
        fundMe.withdraw();

        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.i_owner().balance, startingOwnerBalance + startingFundMeBalance);
    }

    function test_WithdrawWithMultipleFunders() public funded {
        uint160 numberOfFunders = 10;

        for (uint160 i = 1; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.i_owner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.i_owner()); // like vm.prank but covers ALL calls until stopPrank
        fundMe.withdraw();
        vm.stopPrank();

        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.i_owner().balance, startingOwnerBalance + startingFundMeBalance);

        for (uint160 i = 1; i < numberOfFunders; i++) {
            assertEq(fundMe.addressToAmountFunded(address(i)), 0);
        }
    }
}
