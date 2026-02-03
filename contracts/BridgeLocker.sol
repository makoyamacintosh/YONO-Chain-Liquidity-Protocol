// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title BridgeLocker
 * @dev Simple Lock & Mint skeleton: user locks local token; off-chain validator listens to events and mints wrapped token on destination chain.
 */
contract BridgeLocker {
    address public owner;
    event Locked(address indexed token, address indexed sender, uint256 amount, uint256 destChainId, bytes32 destAccount, bytes32 depositId);
    event Unlocked(address indexed token, address indexed to, uint256 amount, bytes32 depositId);

    constructor() { owner = msg.sender; }

    // Lock tokens on source chain. Validators will observe this event and mint on dest chain.
    function lock(address token, uint256 amount, uint256 destChainId, bytes32 destAccount) external {
        ERC20Like(token).transferFrom(msg.sender, address(this), amount);
        bytes32 depositId = keccak256(abi.encodePacked(token, msg.sender, amount, destChainId, destAccount, block.timestamp));
        emit Locked(token, msg.sender, amount, destChainId, destAccount, depositId);
    }

    // Unlock (burn on bridge) is for admin/validators only in this prototype
    function unlock(address token, address to, uint256 amount, bytes32 depositId) external {
        // In production, this would be restricted to validators and include multi-sig / proof
        ERC20Like(token).transfer(to, amount);
        emit Unlocked(token, to, amount, depositId);
    }
}

abstract contract ERC20Like {
    function transferFrom(address from, address to, uint256 value) public virtual;
    function transfer(address to, uint256 value) public virtual;
}
