// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Crowdfunding} from "../src/Crowdfunding.sol";

contract CrowdfundingTest is Test {
    Crowdfunding public crowdfundingContract1Owener1;
    Crowdfunding public crowdfundingContract2Owener1;
    Crowdfunding public crowdfundingContract3Owener2;

    address owner1;
    address owner2;
    address pledger1;
    address pledger2;
    address pledger3;

    function setUp() public {
        owner1 = makeAddr("owner1");
        owner2 = makeAddr("owner2");
        pledger1 = makeAddr("pledger1");
        pledger2 = makeAddr("pledger2");
        pledger3 = makeAddr("pledger3");

        crowdfundingContract1Owener1 = new Crowdfunding(owner1, 1 ether, block.timestamp + 1 days);
        crowdfundingContract2Owener1 = new Crowdfunding(owner1, 1 ether, block.timestamp + 2 days);
        crowdfundingContract3Owener2 = new Crowdfunding(owner2, 1 ether, block.timestamp + 1 days);
    }

    function test_contract1() public {
        assertEq(crowdfundingContract1Owener1.creator(), owner1);
        // assertEq(crowdfundingContract1Owener1.goal(), 1 ether);
        // assertEq(crowdfundingContract1Owener1.claimed(), false);
        // assertEq(uint256(crowdfundingContract1Owener1.getState()), uint256(Crowdfunding.State.Ongoing));

        // vm.prank(pledger1);
        // crowdfundingContract1Owener1.pledge{value: 0.5 ether}();
        // assertEq(crowdfundingContract1Owener1.plegerToAmount(pledger1), 0.5 ether);
        // assertEq(crowdfundingContract1Owener1.plegerToAmount(pledger2), 0 ether);
        // assertEq(address(crowdfundingContract1Owener1).balance, 0.5 ether);

        // assertEq(crowdfundingContract1Owener1.giveback(), Crowdfunding.State.Ongoing);
        // expectRevert();
        // assertEq(crowdfundingContract1Owener1.claim(), "the contract does not belong to pledger1");
    }

    // function test_Increment() public {
    //     counter.increment();
    //     assertEq(counter.number(), 1);
    // }
    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
