// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Crowdfunding.sol";

contract DeployCrowdfunding is Script {
    function run() external {
        // Load private key from env (optional, but nice)
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // constructor(address _creator, uint256 _goal, uint256 _deadline)
        Crowdfunding crowdfunding = new Crowdfunding(
            0xb2944182D46439B43116A0fD57C79c961526d364, // _creator
            1000000, // _goal
            1767797424 // _deadline
        );

        vm.stopBroadcast();
    }
}
