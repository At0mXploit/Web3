// SPDX-License-Identifier: MIT

// Library

pragma solidity ^0.8.18;
// Interfaces allow different contracts to interact seamlessly by ensuring they share a common set of functionalities.
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // Chainlink helps us connect to external network like lets say from ETH to real network like USD which solves the oracle problem

    function getPrice() internal view returns (uint256) {
        // Getting Real World price data from chainlink
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int256 price,,,) = priceFeed.latestRoundData();
        // Price of ETH terms of USD
        // 2000.000000000
        return uint256(price * 1e10); // Type casting
    }
    
    function getConversionRate(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }
    
    function getVersion() internal view returns (uint256) {
         return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }
}
