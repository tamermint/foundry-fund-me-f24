// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    } //always runs first

    function testMinimumDollarIsFive() public view {
        // Arrange
        // Act
        // Assert
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testSenderIsOwner() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
}
