// SPDX-License-Identifier: MIT

//1.purpose is to deploy mocks when we are on a local anvil chain
//2.Keep track of contract address across different chains
//Sepolia ETH/USD
//Mainnet ETH/USD
//Holesky

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/mockV3AggregatorV3.sol";

contract HelperConfig is Script {
    //if on local anvil, deploy mocks
    //otherwise grab existing address from live network

    //now we need to put the address in deploy fund me by retreiving the network config from here
    NetworkConfig public activeNetworkConfig; //if we are on sepolia, we get sepoliaEthConfig but if on anvil, we get anvilEthConfig

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
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

    //if you want to deploy to mainnet
    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        //price feed address
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainnetConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            //if already deployed to default address, no need to deploy again
            return activeNetworkConfig;
        }
        //price feed address
        //1. deploy mocks
        //2. return mock addresses

        vm.startBroadcast(); //create a new pricefeed contract and deploy
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });

        return anvilConfig;
    }
}
