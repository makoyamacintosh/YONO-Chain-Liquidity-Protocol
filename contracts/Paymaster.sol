// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Paymaster (simplified)
 * @dev This paymaster covers gas for transactions it approves by paying the relayer.
 * A real ERC-4337 Paymaster must implement validatePaymasterUserOp and postOp logic.
 * Here we expose a simplified API: relayers call reimburse() after executing sponsored txs.
 */
contract Paymaster {
    address public owner;
    mapping(address => uint256) public sponsored; // account -> allowance in wei

    event Sponsored(address indexed account, uint256 amount);
    event Reimbursed(address indexed relayer, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function fundSponsor(address account, uint256 weiAmount) external payable {
        require(msg.value == weiAmount, "Paymaster: wrong value");
        sponsored[account] += weiAmount;
        emit Sponsored(account, weiAmount);
    }

    // Relayer claims reimbursement (in production, this must be proven)
    function reimburse(address relayer, uint256 amount) external {
        require(sponsored[msg.sender] >= amount, "Paymaster: insufficient");
        sponsored[msg.sender] -= amount;
        payable(relayer).transfer(amount);
        emit Reimbursed(relayer, amount);
    }

    receive() external payable {}
}
