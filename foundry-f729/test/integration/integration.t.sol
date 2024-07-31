// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract IntegrationTest is Test {
    FundMe fundMe;
    address USER = makeAddr("test account's address");
    uint256 public constant INITIAL_ACCOUNT_BALANCE = 100 ether;
    uint256 public constant SEND_VALUE = 1e17;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();

        fundMe = deployFundMe.run();
        vm.deal(USER, INITIAL_ACCOUNT_BALANCE);
    }

    // you have an active prank; broadcasting and pranks are not compatible
    // function testUserCanFundStepOne() external {
    //     FundFundMe fundFundMe = new FundFundMe();
    //     // vm.prank(address(fundFundMe));
    //     vm.prank(USER);
    //     vm.deal(USER, 1e18);
    //     fundFundMe.fundFundMe(address(fundMe));

    //     assertEq(fundMe.getFunder(0), USER);
    // }

    function testUserCanFundInteractions() external {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }
}
