// SPDX-License-Identifier: MIT
pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    // Initialize state variables.
    mapping(address => uint256) public balances;
    
    uint deadline = block.timestamp + 72 hours;
    uint256 public constant threshold = 1 ether;

    event Stake(address staker, uint256 amount);

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
    function stake () public payable {
        require(block.timestamp < deadline, "Deadline has passed");

        // Add the staked amount to the sender's balance
        balances[msg.sender] += msg.value;

        // Log the stake event for the front end. 
        emit Stake(msg.sender, msg.value);
    }

    function execute() public {
        // After some `deadline` allow anyone to call an `execute()` function
        require(block.timestamp >= deadline, "Deadline has not passed yet");
        // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
        if (address(this).balance >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        }
    }

    function withdraw() public {
        // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
        require(address(this).balance < threshold, "Threshold met");

        // Transfer the balance.
        payable(msg.sender).transfer(balances[msg.sender]);

        // Reset the balance.
        balances[msg.sender] = 0;
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        // Note: this is not changing state of the contract. 
        if (block.timestamp >= deadline) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }

    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {
        stake();
    }
}
