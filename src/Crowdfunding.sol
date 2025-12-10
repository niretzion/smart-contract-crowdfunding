pragma solidity ^0.8.13;

/*
A simple crowdfunding contract
The campain start when the contract is deployed, and ends at a specified deadline.

The creator can claim the funds only once, after the deadline, if the goal is reached.
if gol is not reached, pledgers can withdraw their funds.

People can pledge ETH to the campaign until the deadline. after the deadline no more
pledges are accepted.

pledge can be done only by calling the `pledge` function and sending ETH. transfering using
`send` or `transfer` will be rejected.
*/

contract Crowdfunding {
    // Contract State
    enum State {
        Ongoing,
        Successful,
        Failed
    }

    function getState() public view returns (State) {
        if (block.timestamp < deadline) {
            return State.Ongoing;
        }
        if (claimed || address(this).balance >= goal) {
            return State.Successful;
        }
        // if (balance < goal):
        return State.Failed;
    }

    address public creator;
    uint256 public goal;
    uint256 public deadline;
    bool public claimed;

    mapping(address => uint256) public plegerToAmount;

    event Pledged(address pledger, uint256 amount, uint256 totalAfter);
    event GoalReached(uint256 total, uint256 timestamp);
    event Refunded(address pledger, uint256 amount);
    event Claimed(address creator, uint256 amount);

    constructor(address _creator, uint256 _goal, uint256 _deadline) {
        require(_deadline > block.timestamp, "Deadline must be in the future");
        creator = _creator;
        goal = _goal;
        deadline = _deadline;
        claimed = false;
    }

    // Pledge function: send ETH to the contract to pledge
    function pledge() public payable {
        require(getState() == State.Ongoing, "Campaign is not ongoing");
        plegerToAmount[msg.sender] += msg.value;
        emit Pledged(msg.sender, msg.value, address(this).balance);
    }

    // overwrite receive() and fallback() to reject ETH sent using send or transfer
    receive() external payable {
        revert("Please use the pledge function to send ETH");
    }

    fallback() external payable {
        revert("Please use the pledge function to send ETH");
    }

    // Claim function: creator can claim the funds if the goal is reached after the deadline
    function claim() external {
        require(msg.sender == creator, "Only the creator can claim the funds");
        require(getState() == State.Successful, "Campaign is not successful");
        require(!claimed, "Funds have already been claimed");
        claimed = true;
        uint256 amount = address(this).balance;
        (bool ok,) = payable(creator).call{value: amount}("");
        require(ok, "ETH transfer failed");
        emit Claimed(creator, amount);
    }

    // pledgers can withdraw their funds if the goal is not reached after the deadline
    function giveback() external {
        require(getState() == State.Failed, "Campaign is not failed");
        uint256 amount = plegerToAmount[msg.sender];
        require(amount > 0, "No funds to withdraw");
        plegerToAmount[msg.sender] = 0;
        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok, "ETH transfer failed");
        emit Refunded(msg.sender, amount);
    }
}
