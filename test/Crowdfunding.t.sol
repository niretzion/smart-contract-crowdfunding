// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
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
        vm.deal(address(owner1), 1 ether);
        owner2 = makeAddr("owner2");
        vm.deal(address(owner2), 0.1 ether);
        pledger1 = makeAddr("pledger1");
        vm.deal(address(pledger1), 10 ether);
        pledger2 = makeAddr("pledger2");
        vm.deal(address(pledger2), 10 ether);
        pledger3 = makeAddr("pledger3");
        vm.deal(address(pledger3), 10 ether);

        vm.prank(owner1);
        crowdfundingContract1Owener1 = new Crowdfunding(1 ether, block.timestamp + 1 days);
        vm.prank(owner1);
        crowdfundingContract2Owener1 = new Crowdfunding(1 ether, block.timestamp + 2 days);
        vm.prank(owner2);
        crowdfundingContract3Owener2 = new Crowdfunding(1 ether, block.timestamp + 1 days);
    }

    /*
    Test1:
     sanity test for crowdfundingContract1Owener1
     1. check initial contract state, owner, goal, claimed
     3. pledger1 pledge 0.5 ether
     4. check state after pledge
     5. expect revert when pledger1 try to claim funds
     6. expect revert when owner1 try to claim funds before deadline
     7. fast forward time to after deadline
     8. expect revert when owner1 try to claim funds when goal not reached
     9. expect revert , pledger1 pledge another 0.6 ether to reach the goal after deadline
     10. pledger1 get refund
     11. check state after refund, balance should be 0

    Test2:
     1. create new crowdfunding contract by owner1
     2. pledger1 pledge 1.2 ether to reach the goal
     3. fast forward time to after deadline
     4. pledger1 try to get refund - expect revert
     5. owner1 claim funds

    Test3:
     1. create new crowdfunding contract1 by owner1 deadline in 1 day
     2. create new crowdfunding contract2 by owner1 dweadline in 2 days
     3. pledger1 pledge 0.5 ether to contract1
     4. pledger2 pledge 0.7 ether to contract2
     5. pledger1 pledge 0.6 ether to contract1 to reach goal
     6. fast forward time to after deadline of contract1
     7. owner1 claim funds from contract2 - expect revert
     8. owner1 claim funds from contract1

    Test4:
     1. create new crowdfunding contract1 by owner1
     2. create new crowdfunding contract2 by owner2
     3. pledger1 pledge to contract1
     4. pledger2 pledge to contract2
     5. fast forward time to after deadline of contract1 and contract2
     6. owner1 claim funds from contract2 - expect revert
     7. owner2 claim funds from contract1 - expect revert
     8. owner1 claim funds from contract1 - success
     9. owner2 claim funds from contract2 - success

    Test5:
     1. create new crowdfunding contract1 by owner1
     2. pledger1 pledge some ether to contract1
     3. owner1 pledge some ether to his own contract. goal is not reached
     4. owner1 try to claim funds - expect revert
     5. fast forward time to after deadline of contract1
     6. owner1 try to claim funds - expect revert
     7. pledger1 get refund
     8. owner1 get refund.

    Test6:
     1. create new crowdfunding contract1 by owner1
     2. pledger1 pledge some ether to contract1
     3. owner1 pledge some ether to his own contract. goal is reached
     4. fast forward time to after deadline of contract1
     5. owner1 claim funds - success


    Test7: check that GoalReached event is emitted correctly
     1. create new crowdfunding contract1 by owner1
     2. pledger1 pledge some ether to contract1, but not reaching goal - no event expected
     3. pledger2 pledge some ether to contract1, reaching the goal - expect GoalReached event
     3. pledger3 pledge some ether to contract1, after goal reached - no event expected
    */

    // Test1
    function test1_contract1() public {
        assertEq(crowdfundingContract1Owener1.creator(), owner1);
        assertEq(crowdfundingContract1Owener1.GOAL(), 1 ether);
        assertEq(crowdfundingContract1Owener1.claimed(), false);
        assertEq(crowdfundingContract1Owener1.DEADLINE(), block.timestamp + 1 days);
        assertEq(uint8(crowdfundingContract1Owener1.getState()), uint8(Crowdfunding.State.Ongoing));

        vm.prank(pledger1);
        crowdfundingContract1Owener1.pledge{value: 0.5 ether}();
        assertEq(crowdfundingContract1Owener1.pledgerToAmount(pledger1), 0.5 ether);
        assertEq(address(crowdfundingContract1Owener1).balance, 0.5 ether);

        // 5. expect revert when pledger1 try to claim funds
        vm.prank(pledger1);
        vm.expectRevert();
        crowdfundingContract1Owener1.claim();
        // 6. expect revert when owner1 try to claim funds before deadline
        vm.prank(owner1);
        vm.expectRevert();
        crowdfundingContract1Owener1.claim();
        // 7. fast forward time to after deadline
        vm.warp(block.timestamp + 1 days);
        // 8. expect revert when owner1 try to claim funds when goal not reached
        vm.prank(owner1);
        vm.expectRevert();
        crowdfundingContract1Owener1.claim();
        // 9. expect revert , pledger1 pledge another 0.6 ether to reach the goal after deadline
        vm.prank(pledger1);
        vm.expectRevert();
        crowdfundingContract1Owener1.pledge{value: 0.5 ether}();
        //10. pledger1 get refund
        vm.prank(pledger1);
        crowdfundingContract1Owener1.giveback();
        assertEq(crowdfundingContract1Owener1.pledgerToAmount(pledger1), 0);
        // 11. check state after refund, balance should be 0
        assertEq(address(crowdfundingContract1Owener1).balance, 0);
    }

    // Test2:
    function test2_owner1_claims_after_goal_reached() public {
        // 2. pledger1 pledge 1.2 ether to reach the goal
        vm.prank(pledger1);
        crowdfundingContract1Owener1.pledge{value: 1.2 ether}();
        assertEq(address(crowdfundingContract1Owener1).balance, 1.2 ether);
        // 3. fast forward time to after deadline
        vm.warp(block.timestamp + 1 days);
        // 4. pledger1 try to get refund - expect revert
        vm.prank(pledger1);
        vm.expectRevert();
        crowdfundingContract1Owener1.giveback();
        // 5. owner1 claim funds
        uint256 owner1InitialBalance = address(owner1).balance;
        vm.prank(owner1);
        crowdfundingContract1Owener1.claim();
        assertEq(address(crowdfundingContract1Owener1).balance, 0);
        assertEq(address(owner1).balance, owner1InitialBalance + 1.2 ether);
    }

    // Test3:
    function test3_contracts_different_deadlines() public {
        // 3. pledger1 pledge 0.5 ether to contract1
        vm.prank(pledger1);
        crowdfundingContract1Owener1.pledge{value: 0.5 ether}();
        // 4. pledger2 pledge 0.7 ether to contract2
        vm.prank(pledger2);
        crowdfundingContract2Owener1.pledge{value: 0.7 ether}();
        // 5. pledger1 pledge 0.6 ether to contract1 to reach goal
        vm.prank(pledger1);
        crowdfundingContract1Owener1.pledge{value: 0.6 ether}();
        // 6. fast forward time to after deadline of contract1
        vm.warp(block.timestamp + 1 days);
        // 7. owner1 claim funds from contract2 - expect revert
        vm.prank(owner1);
        vm.expectRevert();
        crowdfundingContract2Owener1.claim();
        // 8. owner1 claim funds from contract1
        vm.prank(owner1);
        crowdfundingContract1Owener1.claim();
    }

    function test4_pledge_different_owners() public {
        // 3. contract1 goal reached by pledger1
        vm.prank(pledger1);
        crowdfundingContract1Owener1.pledge{value: 1 ether}();

        // 4. contract3 goal reached by pledger2
        vm.prank(pledger2);
        crowdfundingContract3Owener2.pledge{value: 1 ether}();

        // 5. fast forward time to after deadline of contract1 and contract3
        vm.warp(block.timestamp + 1 days);

        // 6. owner1 claim funds from contract3 - expect revert
        vm.prank(owner1);
        vm.expectRevert();
        crowdfundingContract3Owener2.claim();
        // 7. owner2 claim funds from contract1 - expect revert
        vm.prank(owner2);
        vm.expectRevert();
        crowdfundingContract1Owener1.claim();

        // 8. owner1 claim funds from contract1 - success
        uint256 owner1InitialBalance = address(owner1).balance;
        vm.prank(owner1);
        crowdfundingContract1Owener1.claim();
        assertEq(address(crowdfundingContract1Owener1).balance, 0);
        assertEq(address(owner1).balance, owner1InitialBalance + 1 ether);

        // 9. owner2 claim funds from contract3 - success
        uint256 owner2InitialBalance = address(owner2).balance;
        vm.prank(owner2);
        crowdfundingContract3Owener2.claim();
        assertEq(address(crowdfundingContract3Owener2).balance, 0);
        assertEq(address(owner2).balance, owner2InitialBalance + 1 ether);
    }

    // Test5:
    function test5_owner_pledge_no_goal_reached() public {
        // Crowdfunding crowdfundingContract = new Crowdfunding(owner1, 2 ether, block.timestamp + 1 days);
        // 2. pledger1 pledge some ether to contract1
        vm.prank(pledger1);
        crowdfundingContract1Owener1.pledge{value: 0.2 ether}();
        // 3. owner1 pledge some ether to his own contract. goal is not reached
        vm.prank(owner1);
        crowdfundingContract1Owener1.pledge{value: 0.3 ether}();
        // 4. owner1 try to claim funds - expect revert
        vm.prank(owner1);
        vm.expectRevert();
        crowdfundingContract1Owener1.claim();
        // 5. fast forward time to after deadline of contract1
        vm.warp(block.timestamp + 1 days);
        // 6. owner1 try to claim funds - expect revert
        vm.prank(owner1);
        vm.expectRevert();
        crowdfundingContract1Owener1.claim();
        // 7. pledger1 get refund
        vm.prank(pledger1);
        crowdfundingContract1Owener1.giveback();
        assertEq(crowdfundingContract1Owener1.pledgerToAmount(pledger1), 0);
        assertEq(address(crowdfundingContract1Owener1).balance, 0.3 ether);
        assertEq(address(pledger1).balance, 10 ether); // gas is not deducted in tests, we it still has 10 eth
        // 8. owner1 get refund.
        vm.prank(owner1);
        crowdfundingContract1Owener1.giveback();
        assertEq(crowdfundingContract1Owener1.pledgerToAmount(owner1), 0);
    }

    function test6_owner_pledges_to_reach_goal() public {
        // 2. pledger1 pledge some ether to contract1
        vm.prank(pledger1);
        crowdfundingContract1Owener1.pledge{value: 0.5 ether}();

        // 3. owner1 pledges some ether to his own contract. goal is reached
        vm.prank(owner1);
        crowdfundingContract1Owener1.pledge{value: 0.6 ether}();

        // 4. fast forward time to after deadline of contract1
        vm.warp(block.timestamp + 1 days);

        // 5. owner1 claim funds - success
        uint256 owner1InitialBalance = address(owner1).balance;
        vm.prank(owner1);
        crowdfundingContract1Owener1.claim();
        assertEq(address(crowdfundingContract1Owener1).balance, 0);
        assertEq(address(owner1).balance, owner1InitialBalance + 1.1 ether);
    }

    function test7_goal_reached_event() public {
        // 2. pledger1 pledge some ether to contract1, but not reaching goal - no event expected
        vm.prank(pledger1);
        crowdfundingContract1Owener1.pledge{value: 0.4 ether}();

        Vm.Log[] memory logs1 = vm.getRecordedLogs();
        assertFalse(_goalReachedEmitted(address(crowdfundingContract1Owener1), logs1));

        // 3. pledger2 pledge some ether to contract1, reaching the goal - expect GoalReached event
        vm.prank(pledger2);
        vm.expectEmit(false, false, false, false);
        emit Crowdfunding.GoalReached(1.1 ether, block.timestamp);
        crowdfundingContract1Owener1.pledge{value: 0.7 ether}();

        Vm.Log[] memory logs2 = vm.getRecordedLogs();
        assertTrue(_goalReachedEmitted(address(crowdfundingContract1Owener1), logs2));

        // 4. pledger3 pledge some ether to contract1, after goal reached - no event expected
        vm.prank(pledger3);
        crowdfundingContract1Owener1.pledge{value: 0.5 ether}();

        Vm.Log[] memory logs3 = vm.getRecordedLogs();
        assertFalse(_goalReachedEmitted(address(crowdfundingContract1Owener1), logs3));
    }

    function test8_update_creator_address() public {
        // Owner1 updates the creator address to pledger1
        vm.prank(owner1);
        crowdfundingContract1Owener1.updateCreator(pledger1);
        assertEq(crowdfundingContract1Owener1.creator(), pledger1);

        // Owner2 tries to update the creator address - expect revert
        vm.prank(owner2);
        vm.expectRevert();
        crowdfundingContract1Owener1.updateCreator(pledger2);
        assertEq(crowdfundingContract1Owener1.creator(), pledger1);

        // Now pledger1 should be able to claim funds after goal is reached and deadline passed
        // Pledger1 pledges to reach the goal
        vm.prank(pledger1);
        crowdfundingContract1Owener1.pledge{value: 1.2 ether}();

        // Fast forward time to after deadline
        vm.warp(block.timestamp + 1 days);

        // Pledger1 claims the funds
        uint256 pledger1InitialBalance = address(pledger1).balance;
        vm.prank(pledger1);
        crowdfundingContract1Owener1.claim();
        assertEq(address(crowdfundingContract1Owener1).balance, 0);
        assertEq(address(pledger1).balance, pledger1InitialBalance + 1.2 ether);
    }

    function test9_pledge_minimum_amount() public {
        // Pledger1 tries to pledge less than the minimum amount - expect revert
        vm.prank(pledger1);
        vm.expectRevert(bytes("Pledge amount must be greater than 0.001 ETH"));
        crowdfundingContract1Owener1.pledge{value: 0.0005 ether}();

        // Pledger1 pledges the minimum amount successfully
        vm.prank(pledger1);
        crowdfundingContract1Owener1.pledge{value: 0.002 ether}();
        assertEq(crowdfundingContract1Owener1.pledgerToAmount(pledger1), 0.002 ether);
    }

    function _goalReachedEmitted(address emitter, Vm.Log[] memory logs) internal pure returns (bool) {
        bytes32 sig = keccak256("GoalReached(uint256,uint256)");
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].emitter == emitter && logs[i].topics.length > 0 && logs[i].topics[0] == sig) {
                return true;
            }
        }
        return false;
    }
}
