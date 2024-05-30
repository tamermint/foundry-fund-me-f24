// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        //get the active network config
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        //if you had multiple addresses or values to return from a struct
        //(address ethUsdPriceFeed, , ,) = helperConfig.activeNetworkConfig()

        //before broadcast -> not a tx
        vm.startBroadcast();
        //after broadcast -> tx
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
