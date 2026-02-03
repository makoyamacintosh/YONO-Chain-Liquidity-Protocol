// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./WrappedToken.sol";

/**
 * @title WrappedTokenFactory
 * @dev Deploys WrappedToken clones for cross-chain representations.
 * In production you'd use minimal proxies and track canonical asset mapping per chain.
 */
contract WrappedTokenFactory {
    event WrappedTokenCreated(address indexed tokenAddress, string name, string symbol);

    mapping(bytes32 => address) public getWrapped; // mapping canonicalId => wrapped token address

    function createWrappedToken(string calldata name, string calldata symbol, bytes32 canonicalId) external returns (address) {
        require(getWrapped[canonicalId] == address(0), "WrappedTokenFactory: exists");
        WrappedToken token = new WrappedToken(name, symbol, address(this));
        getWrapped[canonicalId] = address(token);
        emit WrappedTokenCreated(address(token), name, symbol);
        return address(token);
    }

    function mintWrapped(bytes32 canonicalId, address to, uint256 amount) external {
        address token = getWrapped[canonicalId];
        require(token != address(0), "WrappedTokenFactory: none");
        WrappedToken(token).mint(to, amount);
    }

    function burnWrapped(bytes32 canonicalId, address from, uint256 amount) external {
        address token = getWrapped[canonicalId];
        require(token != address(0), "WrappedTokenFactory: none");
        WrappedToken(token).burn(from, amount);
    }
}
