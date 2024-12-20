//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Test ,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant GAS_PRICE = 1;
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
        assertEq(fundMe.getOwner(), msg.sender);
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
    function testAddsFunderToArrayOfFunders() public{
        vm.prank(USER);
        fundMe.fund{value : SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder ,USER);
    }
    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value : SEND_VALUE}();
        _;
    }
    function testOnlyOwnerCanWithdraw() public funded(){
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }
    function testWithDrawWithSingleFunder() public funded(){  // Arrange
       uint256 startingOwnerBalance = fundMe.getOwner().balance;
       uint256 startingFundMeBalance = address(fundMe).balance;
       //Act
       vm.prank(fundMe.getOwner());
       fundMe.withdraw();
       //Assert
       uint256 endingOwnerBalance = fundMe.getOwner().balance;
       uint256 endingFundMeBalance = address(fundMe).balance;
       assertEq(endingFundMeBalance,0);
       assertEq(startingFundMeBalance +startingOwnerBalance,endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded(){
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i =startingFunderIndex; i<numberOfFunders;i++){
            hoax(address(i),SEND_VALUE);// do both deal and prank
             fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance; 
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        // assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance);
    }
    function testWithdrawFromMultipleFundersCheaper() public funded(){
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i =startingFunderIndex; i<numberOfFunders;i++){
            hoax(address(i),SEND_VALUE);// do both deal and prank
             fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance; 
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        // assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance);
    }
}
//12:40

//Different types of test
// 1. Unit - Testing a specific part of our code
// 2. Integration - Testing how different parts of our code work together
// 3. Forked - Testing our code in a simulated real environment
// 4. Staging - Testing our code in a real environment that is not prod
