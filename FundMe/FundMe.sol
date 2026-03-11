// Get Funds from users
// Withdraw Funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {

    using PriceConverter for uint256;

    // Using constant saves gas

    uint256 public constant MINIMUM_USD = 5e18; // 5 USD with 18 decimals

    // view functions have gas cost when called by contracts
    
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    // Immutable also saves gas but use it when we are using that variable somewhere else too like inside another function scope or constructor scope etc

    address public immutable i_owner;

    constructor() { // Immediately called when you deploy your contract
        i_owner = msg.sender;
    }

    // payable keyword enable function or addr to recieve hold or transfer Ether
    function fund() public payable{
        require(msg.value.getConversionRate() >= MINIMUM_USD, "didn't sent enough Eth"); // Check if ETH sent meets USD minimum

        // If a transaction reverts, is defined as failed
        // Revert ? => Undos any actions that have been done, and send the remaining gas back
        
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // Reset the array i.e addresses
        funders = new address[](0);

        // Methods for sending ETH from contract
        // transfer = max 2300 gas throws error
        // send = max 2300 gas returns bool
        // call = Best way and no max gas cap, forward all gas or set gas, returns bool so it returns two value
        // payable(msg.sender) = payable address
        // payable(msg.sender).transfer(address(this).balance);
        // bool sendSucess = payable(msg.sender).send(address(this).balance);
        // require(sendSucess, "Send Failed");

        // In call we get two value in return but we only take one
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    // modifier = reusable piece of code that can be attached to function to modify its behavior
    modifier onlyOwner() {
        // require was good but we can create our custom errors to optimize gas price 
        // require(msg.sender == i_owner, "Sender is not owner!");
        if(msg.sender != i_owner) {
          revert NotOwner();
        }
        _; // Do above part and then whatever the fuck is in anotehr part of function
    }
}
