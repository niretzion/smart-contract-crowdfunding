// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Crowdfunding} from "../src/Crowdfunding.sol";

contract DeployCrowdfunding is Script {
    function run() external {
        // Load private key from env (optional, but nice)
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // constructor(address _creator, uint256 _goal, uint256 _deadline)
        Crowdfunding crowdfunding = new Crowdfunding(
            1000000, // _goal
            1769255521 // _deadline
        );

        console2.log("Crowdfunding deployed at:", address(crowdfunding));

        vm.stopBroadcast();
    }
}
