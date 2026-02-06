// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title FeeCollector
 * @dev Collects swap fees and funds the paymaster (gas subsidy pool).
 */
contract FeeCollector {
    address public owner;
    mapping(address => uint256) public collected; // token => amount
    address public paymaster;

    event FeeCollected(address indexed token, uint256 amount);
    event PaymasterSet(address indexed paymaster);
    event Withdraw(address indexed to, address token, uint256 amount);

    constructor(address _paymaster) {
        owner = msg.sender;
        paymaster = _paymaster;
    }

    function collect(address token, uint256 amount) external {
        // In actual practice pairs would call collect after each swap (transfer tokens to collector)
        ERC20Like(token).transferFrom(msg.sender, address(this), amount);
        collected[token] += amount;
        emit FeeCollected(token, amount);
    }

    function setPaymaster(address _paymaster) external {
        require(msg.sender == owner, "FeeCollector: only owner");
        paymaster = _paymaster;
        emit PaymasterSet(_paymaster);
    }

    function withdraw(address to, address token, uint256 amount) external {
        require(msg.sender == owner, "FeeCollector: only owner");
        require(collected[token] >= amount, "FeeCollector: insufficient");
        collected[token] -= amount;
        ERC20Like(token).transfer(to, amount);
        emit Withdraw(to, token, amount);
    }
}

abstract contract ERC20Like {
    function transferFrom(address from, address to, uint256 amount) public virtual;
    function transfer(address to, uint256 amount) public virtual;
}
