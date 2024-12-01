pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe ,WithDrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 SEND_VALUE = 0.1 ether;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUseCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithDrawFundMe withdrawFundMe = new WithDrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        
        assert(address(fundMe).balance ==0);
    }
}
