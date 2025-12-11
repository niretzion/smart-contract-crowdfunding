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

    /*
     sanity test for crowdfundingContract1Owener1
     1. check initial state
     2. pledger1 pledge 0.5 ether
     3. check state after pledge
     4. expect revert when pledger1 try to claim funds
     5. expect revert when owner1 try to claim funds before deadline
     6. fast forward time to after deadline
     7. expect revert when owner1 try to claim funds when goal not reached
     8. expect reveert , pledger1 pledge another 0.6 ether to reach the goal after deadline
     9. pleger1 get refund
     10. check state after refund, balance should be 0

     1. create new crowdfunding contract by owner1
     2. pledger1 pledge 1.2 ether to reach the goal
     3. fast forward time to after deadline
     4. pledger1 try to get refund - expect revert
     5. owner1 claim funds

     1. create new crowdfunding contract1 by owner1 deadline in 1 day
     2. create new crowdfunding contract2 by owner1 dweadline in 2 days
     3. pledger1 pledge 0.5 ether to contract1
     4. pledger2 pledge 0.7 ether to contract2
     5. fast forward time to after deadline of contract1
     6. owner1 claim funds from contract2 - expect revert

     1. create new crowdfunding contract1 by owner1
     2. create new crowdfunding contract2 by owner2
     3. pledger1 pledge to contract1
     4. pledger2 pledge to contract2
     5. fast forward time to after deadline of contract1 and contract2
     6. owner1 claim funds from contract2 - expect revert
     7. owner2 claim funds from contract1 - expect revert
     8. owner1 claim funds from contract1 - success
     9. owner2 claim funds from contract2 - success

     1. create new crowdfunding contract1 by owner1
     2. pledger1 pledge some ether to contract1
     3. owner1 pledge some ether to his own contract. goal is not reached
     4. owner1 try to claim funds - expect revert
     5. fast forward time to after deadline of contract1
     6. owner1 try to claim funds - expect revert
     7. pledger1 get refund
     8. owner1 get refund.


     1. create new crowdfunding contract1 by owner1
     2. pledger1 pledge some ether to contract1
     3. owner1 pledge some ether to his own contract. goal is reached
     4. fast forward time to after deadline of contract1
     5. owner1 claim funds - success
     */

    function test_contract1() public {
        // assertEq(crowdfundingContract1Owener1.creator(), owner1);
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
}
