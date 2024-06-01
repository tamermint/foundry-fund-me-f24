// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe public fundMe;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    /* uint256 constant GAS_PRICE = 1; */

    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    } //always runs first

    function testUserCanFundInteractions() public {
        FundFundMe fundfundMe = new FundFundMe(); // first you create an object of type FundFundMe
        fundfundMe.fundFundMe(address(fundMe)); //utlize a function (single function here only) within that object
        /*   vm.prank(USER);
        vm.deal(USER, 1e18);
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER); */
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe(); // first you create an object of type WithdrawFundMe
        withdrawFundMe.withdrawFundMe(address(fundMe)); //utlize a function (single function here only) within that object

        assert(address(fundMe).balance == 0);
    }
}
