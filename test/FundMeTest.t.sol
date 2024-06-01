// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
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

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); //means we are expecting foundry to revert
        fundMe.fund();
    }

    modifier funded() {
        //helps to emulate the msg.sender as owner and we don't have to repeat this in every test
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesFundedDataStructure() public funded {
        //tests whether the value gets updated against the correct address
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFunderToArrayOfFunders() public funded {
        //tests whether funder is getting added to the array
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        //tests whether onlyOwner modifier is working
        vm.expectRevert(); //next step i.e. fundMe.withdraw to revert as vm.prank must revert
        vm.prank(USER); //reverts the user
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingContractBalance = address(fundMe).balance;
        //Act
        /*  uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE); */
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        /* uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; */
        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingContractBalance = address(fundMe).balance;
        assertEq(endingContractBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingContractBalance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; //can't start with 0 because 0 address might revert due to solidity sanity checks
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //make dummy address i.e. prank ---| Both of these can be acheived via 'hoax'
            hoax(address(i), SEND_VALUE);
            //deal money to these address -----| one thing to keep in mind, uint256 can't be converted to address type but uint160 can
            //fund the fundMe contract
            fundMe.fund{value: SEND_VALUE}();
        }
        //Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingContractBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingContractBalance = address(fundMe).balance;
        assertEq(endingContractBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingContractBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; //can't start with 0 because 0 address might revert due to solidity sanity checks
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //make dummy address i.e. prank ---| Both of these can be acheived via 'hoax'
            hoax(address(i), SEND_VALUE);
            //deal money to these address -----| one thing to keep in mind, uint256 can't be converted to address type but uint160 can
            //fund the fundMe contract
            fundMe.fund{value: SEND_VALUE}();
        }
        //Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingContractBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingContractBalance = address(fundMe).balance;
        assertEq(endingContractBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingContractBalance
        );
    }
}
