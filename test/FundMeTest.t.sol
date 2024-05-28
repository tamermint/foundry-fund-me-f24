// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe public fundMe;

    function setUp() external {
        fundMe = new FundMe();
    } //always runs first

    function testMinimumDollarIsFive() public view {
        // Arrange
        // Act
        // Assert
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testSenderIsOwner() public view {
        assertEq(fundMe.i_owner(), address(this));
    }
}
