// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract FallbackExample {
  uint256 public result;
  
  // receive() function is called when:
  // 1. Someone sends ETH to this contract with NO data (empty calldata)
  // 2. Plain ETH transfers like: address(contract).transfer() or address(contract).send()
  // This function MUST be marked as 'external payable' and cannot have arguments or return values
  receive() external payable {
    result = 1;
  }
  
  // fallback() function is called when:
  // 1. Someone sends ETH to this contract WITH data, but no matching function exists
  // 2. Someone calls a function that doesn't exist in the contract
  // 3. If receive() doesn't exist and plain ETH is sent
  // This acts as a "catch-all" for unexpected calls
  fallback() external payable {
    result = 2;
  }
}
