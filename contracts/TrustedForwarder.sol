// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title TrustedForwarder (EIP-2771 minimal)
 * @dev This forwarder allows relayers to submit meta-transactions on behalf of users.
 * It stores the original sender at the end of calldata as per EIP-2771.
 * For production use OpenZeppelin's TrustedForwarder.
 */
contract TrustedForwarder {
    event MetaTransactionExecuted(address indexed from, address indexed to, bytes data);

    // NOTE: This is a minimal example. Real forwarders must handle signatures, nonces, and replay protection.

    function forward(address target, bytes calldata data, address user) external {
        // Forward call to target with msg.sender set to this contract and original user appended
        (bool success, ) = target.call(abi.encodePacked(data, abi.encode(user)));
        require(success, "TrustedForwarder: call failed");
        emit MetaTransactionExecuted(user, target, data);
    }
}
