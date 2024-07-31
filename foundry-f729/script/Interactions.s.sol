// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 public constant SEND_VALUE = 1 ether;

    function fundFundMe(address fundMeRecentlyAddress) public {
        vm.startBroadcast();
        FundMe fundMe = FundMe(payable(fundMeRecentlyAddress));
        fundMe.fund{value: SEND_VALUE}();
        vm.stopBroadcast();

        console2.log("Funded fundMe with %s", SEND_VALUE);
    }

    function run() external {
        address fundMeRecentlyAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        fundFundMe(fundMeRecentlyAddress);
    }
}

contract WithdrawFundMe is Script {
    uint256 public constant SEND_VALUE = 1 ether;

    function withdrawFundMe(address fundMeRecentlyAddress) public {
        vm.startBroadcast();
        FundMe fundMe = FundMe(payable(fundMeRecentlyAddress));
        fundMe.withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address fundMeRecentlyAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(fundMeRecentlyAddress);
    }
}
