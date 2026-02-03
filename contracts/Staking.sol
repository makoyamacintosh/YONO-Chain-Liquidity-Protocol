// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Staking
 * @dev Very simple LP staking that accrues rewards linearly.
 */
contract Staking {
    address public owner;
    mapping(address => mapping(address => uint256)) public staked; // user -> token -> amount
    mapping(address => uint256) public rewardRate; // token -> wei per second per token staked

    event Staked(address indexed user, address token, uint256 amount);
    event Unstaked(address indexed user, address token, uint256 amount);

    constructor() { owner = msg.sender; }

    function stake(address token, uint256 amount) external {
        ERC20Like(token).transferFrom(msg.sender, address(this), amount);
        staked[msg.sender][token] += amount;
        emit Staked(msg.sender, token, amount);
    }

    function unstake(address token, uint256 amount) external {
        require(staked[msg.sender][token] >= amount, "Staking: insufficient");
        staked[msg.sender][token] -= amount;
        ERC20Like(token).transfer(msg.sender, amount);
        emit Unstaked(msg.sender, token, amount);
    }
}

abstract contract ERC20Like {
    function transferFrom(address from, address to, uint256 amount) public virtual;
    function transfer(address to, uint256 amount) public virtual;
}
