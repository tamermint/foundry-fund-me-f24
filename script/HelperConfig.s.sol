// SPDX-License-Identifier: MIT

//1.purpose is to deploy mocks when we are on a local anvil chain
//2.Keep track of contract address across different chains
//Sepolia ETH/USD
//Mainnet ETH/USD
//Holesky

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    //if on local anvil, deploy mocks
    //otherwise grab existing address from live network

    //now we need to put the address in deploy fund me by retreiving the network config from here
    NetworkConfig public activeNetworkConfig; //if we are on sepolia, we get sepoliaEthConfig but if on anvil, we get anvilEthConfig

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed; //ETHUSD price feedaddress
        //vrf address
        //chain id
        //gas price .. to get  these we create a struct
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        }); //so that we are getting the price feed object
        return sepoliaConfig;
    }

    function getAnvilEthConfig() public pure returns (NetworkConfig memory) {
        //price feed address
    }
}
