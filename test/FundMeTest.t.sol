//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Test ,console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant SEND_VALUE = 0.1 ether;
    function setUp() external{
        //  fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // give fake balance
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }
    function testOwnwerIsMessage() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }
    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
    function testFundFailsWithoutEnoughETH () public{
        vm.expectRevert(); //use or it passed when code or line below it fails 
        fundMe.fund();
    }
    function testFundUpdatesFundDataStructure () public{
        vm.prank(USER); //the next transcation will be send by user
        fundMe.fund{value : SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded , SEND_VALUE);
    }
} //12:00:48
//Different types of test
// 1. Unit - Testing a specific part of our code
// 2. Integration - Testing how different parts of our code work together
// 3. Forked - Testing our code in a simulated real environment
// 4. Staging - Testing our code in a real environment that is not prod
