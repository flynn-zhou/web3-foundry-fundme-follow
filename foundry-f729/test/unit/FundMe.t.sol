// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract TestFundMe is Test {
    FundMe fundMe;
    address USER = makeAddr("test account's address");
    uint256 public constant INITIAL_ACCOUNT_BALANCE = 100 ether;
    uint256 public constant SEND_VALUE = 1e17;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        fundMe = deployFundMe.run();
        vm.deal(USER, INITIAL_ACCOUNT_BALANCE);
    }

    function testOwnerIsMsgSender() external view {
        address owner = fundMe.getOwner();
        assertEq(owner, msg.sender);
    }

    function testGetVersionIsCorecct() external view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailNonEnoughEth() external {
        vm.expectRevert();
        fundMe.fund();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundedMappingBalanceCorectly() external funded {
        assertEq(fundMe.addressToAmountFunded(USER), SEND_VALUE);
    }

    function testAddFundersCorectly() external funded {
        assertEq(fundMe.getFunder(0), USER);
    }

    function testOnlyOwnerCanWithdraw() external funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawBalances() external funded {
        address owner = fundMe.getOwner();
        uint256 startOwnerBalance = owner.balance;
        uint256 startFundMeBalance = address(fundMe).balance;

        vm.prank(owner);
        fundMe.withdraw();

        uint256 endOwnerBalance = owner.balance;
        uint256 endFundMeBalance = address(fundMe).balance;

        assertEq(endFundMeBalance, 0);

        assertEq(startOwnerBalance + startFundMeBalance, endOwnerBalance);
    }

    function testWithdrawAfterMultiFunders() external funded {
        uint160 i = 10;
        uint160 startIndex = 1;
        for (uint160 j = startIndex; j < i; j++) {
            hoax(address(j), INITIAL_ACCOUNT_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        address owner = fundMe.getOwner();
        uint256 startOwnerBalance = owner.balance;
        uint256 startFundMeBalance = address(fundMe).balance;

        vm.prank(owner);
        fundMe.withdraw();

        uint256 endOwnerBalance = owner.balance;
        uint256 endFundMeBalance = address(fundMe).balance;

        assertEq(endFundMeBalance, 0);

        assertEq(startOwnerBalance + startFundMeBalance, endOwnerBalance);
    }
}
