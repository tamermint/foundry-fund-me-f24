// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

//purpose of this contract is for users to send money to contract
contract FundMe {
    using PriceConverter for uint256; //lets me use the price converter library functions here directly
    //mapping to store the address of the sender and the amount they sent
    mapping(address => uint256) private s_fundersToAmountFunded;

    //array to store the addresses of the funders
    address[] private s_funders;

    //minimum usd required to send money to the contract
    uint256 public constant MINIMUM_USD = 5e18;

    //owner of this contract needs to be immutable
    address public immutable i_owner; //initialised once when the contract is deployed

    //initializing a AggregatorV3 interface variable so that we can deploy using this variable in the constructor
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender; //msg.sender is the address that deployed the contract
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    //now the fund function
    function fund() public payable {
        //check if the amount sent is greater than or equal to the minimum
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough!"
        );
        //update the mapping
        s_fundersToAmountFunded[msg.sender] += msg.value;
        //need to update the array
        s_funders.push(msg.sender);
    }

    //use a onlyOwner modifier
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    //cheaper withdraw function
    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_fundersToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }(""); //the total money in this contract
        require(callSuccess, "Call failed");
    }

    //withdraw money from this contract
    function withdraw() public onlyOwner {
        //transfer the money to the owner
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_fundersToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0); //reset the array

        //transfer amount to owner using call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }(""); //the total money in this contract
        require(callSuccess, "Call failed");
    }

    //receive and fallback functions to handle user tx
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    //View and Pure functions - our getters
    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(
        address sender
    ) external view returns (uint256) {
        return s_fundersToAmountFunded[sender];
    }
}
