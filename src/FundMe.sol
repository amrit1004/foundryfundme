// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from './PriceConverter.sol';

error FundMe_NotOwner();


contract FundMe {
   using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

     constructor(address priceFeed) {
           i_owner = msg.sender;
           s_priceFeed = AggregatorV3Interface(priceFeed);
     }

    function fund() public payable {
      
        require(msg.value.getConversionRate(s_priceFeed)>= MINIMUM_USD,"didn't send enough eth"); // 1e18 = 1ETH = 1* 10 base 18 wei
        funders.push(msg.sender); // whoever call this function
          addressToAmountFunded[msg.sender] += msg.value;
    }
   function withdraw() public onlyOwner{
     for(uint256 funderIndex = 0; funderIndex <funders.length; funderIndex++){
         address funder = funders[funderIndex];
         addressToAmountFunded[funder] =0;
     }
     funders = new address[](0); // resetting the array
     //using transfer
    //  payable(msg.sender).transfer(address(this).balance); // sending eth
    //  //send
    //  bool sendSuccess = payable(msg.sender).send(address(this).balance);
    //  require(sendSuccess ,"Send Failed");
     //call
    (bool callSuccess,)= payable(msg.sender).call{value: address(this).balance}("");
    require(callSuccess ,"Call Failed");
   }
   function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

   modifier onlyOwner(){
    if (msg.sender != i_owner) revert FundMe_NotOwner();
    _;
   } 
   // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

}

