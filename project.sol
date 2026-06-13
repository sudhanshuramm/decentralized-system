// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CentralizedVault {
    address public owner;

    // Mapping to store registered users and their internal balances
    mapping(address => bool) public isRegistered;
    mapping(address => uint256) public internalBalance;

    constructor() {
        owner = msg.sender;
    }

    // Register a new user (only owner can register)
    function registerUser(address user) external {
        require(msg.sender == owner, "Only owner can register users");
        require(!isRegistered[user], "User already registered");
        isRegistered[user] = true;
    }

    // Deposit ETH to the contract and credit internal balance
    function deposit() external payable {
        require(isRegistered[msg.sender], "You must be registered to deposit");
        require(msg.value > 0, "Must send some ETH");

        internalBalance[msg.sender] += msg.value;
    }

    // Transfer internal balance to another registered user
    function transfer(address to, uint256 amount) external {
        require(isRegistered[msg.sender], "Sender not registered");
        require(isRegistered[to], "Receiver not registered");
        require(internalBalance[msg.sender] >= amount, "Insufficient balance");

        internalBalance[msg.sender] -= amount;
        internalBalance[to] += amount;
    }

    // Withdraw ETH from internal balance
    function withdraw(uint256 amount) external {
        require(isRegistered[msg.sender], "You must be registered to withdraw");
        require(internalBalance[msg.sender] >= amount, "Insufficient balance");

        internalBalance[msg.sender] -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "ETH transfer failed");
    }

    // Get contract balance
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
