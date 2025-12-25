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
        OngoingGoalReached,
        EndedGoalReached,
        EndedGoalNotReached
    }

    function getState() public view returns (State) {
        if (block.timestamp < deadline) {
            if (address(this).balance < goal) {
                return State.Ongoing;
            }
            return State.OngoingGoalReached;
        }
        if (address(this).balance >= goal) {
            return State.EndedGoalReached;
        }
        return State.EndedGoalNotReached;
    }

    address public creator;
    uint256 public immutable goal;
    uint256 public immutable deadline;
    bool public claimed;

    mapping(address => uint256) public pledgerToAmount;

    event Pledged(address pledger, uint256 amount, uint256 totalAfter);
    event GoalReached(uint256 total, uint256 timestamp);
    event Refunded(address pledger, uint256 amount);
    event Claimed(address creator, uint256 amount);

    // making the deployer the creator for simplicity
    constructor(uint256 _goal, uint256 _deadline) {
        require(_deadline > block.timestamp, "Deadline must be in the future");
        require(_goal > 0, "Goal must be greater than 0");
        creator = msg.sender;
        goal = _goal;
        deadline = _deadline;
        claimed = false;
    }

    // Pledge function: send ETH to the contract to pledge
    function pledge() external payable {
        require(msg.value > 0.001 ether, "Pledge amount must be greater than 0.001 ETH");

        State currentState = getState();
        require(currentState == State.Ongoing || currentState == State.OngoingGoalReached, "Campaign is not ongoing");
        pledgerToAmount[msg.sender] += msg.value;

        emit Pledged(msg.sender, msg.value, address(this).balance);
        // TODO: check if i need to add a line that trasfers the ETH to the contract?
        // Answer: just by making the method payable, the ETH is automatically sent to the contract
        uint256 afterBalance = address(this).balance;
        uint256 beforeBalance = afterBalance - msg.value;
        if (beforeBalance < goal && afterBalance >= goal) {
            emit GoalReached(address(this).balance, block.timestamp);
        }
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
        require(getState() == State.EndedGoalReached, "Campaign is not successful Ended");
        require(!claimed, "Funds have already been claimed");
        claimed = true;
        uint256 amount = address(this).balance;
        (bool ok,) = payable(creator).call{value: amount}("");
        require(ok, "ETH transfer failed");
        emit Claimed(creator, amount);
    }

    // pledgers can withdraw their funds if the goal is not reached after the deadline
    function giveback() external {
        require(getState() == State.EndedGoalNotReached, "Campaign is not failed");
        uint256 amount = pledgerToAmount[msg.sender];
        require(amount > 0, "No funds to withdraw");
        pledgerToAmount[msg.sender] = 0;
        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok, "ETH transfer failed");
        emit Refunded(msg.sender, amount);
    }

    function updateCreator(address newCreator) external {
        require(msg.sender == creator, "Only the creator can update the creator address");
        creator = newCreator;
    }
}
