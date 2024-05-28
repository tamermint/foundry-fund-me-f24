// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

//purpose of this contract is for users to send money to contract
contract FundMe {
    using PriceConverter for uint256; //lets me use the price converter library functions here directly
    //mapping to store the address of the sender and the amount they sent
    mapping(address => uint256) public fundersToAmountFunded;

    //array to store the addresses of the funders
    address[] public funders;

    //minimum usd required to send money to the contract
    uint256 public constant MINIMUM_USD = 5e18;

    //owner of this contract needs to be immutable
    address public immutable i_owner; //initialised once when the contract is deployed

    constructor() {
        i_owner = msg.sender; //msg.sender is the address that deployed the contract
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        return priceFeed.version();
    }

    //now the fund function
    function fund() public payable {
        //check if the amount sent is greater than or equal to the minimum
        require(
            msg.value.getConversionRate() >= MINIMUM_USD,
            "Didn't send enough!"
        );
        //update the mapping
        fundersToAmountFunded[msg.sender] += msg.value;
        //need to update the array
        funders.push(msg.sender);
    }

    //use a onlyOwner modifier
    modifier onlyOwner() {
        if (msg.sender == i_owner) revert FundMe__NotOwner();
        _;
    }

    //withdraw money from this contract
    function withdraw() public onlyOwner {
        //transfer the money to the owner
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            fundersToAmountFunded[funder] = 0;
        }
        funders = new address[](0); //reset the array

        //transfer amount to owner using call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }(""); //the total money in this contract
        require(callSuccess, "Call failed");
    }
}
