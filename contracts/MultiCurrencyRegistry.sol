// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title MultiCurrencyRegistry
 * @dev Maintains metadata and known tokens across chains.
 * In a multi-chain deployment this registry would be deployed per chain and/or indexed off-chain.
 */
contract MultiCurrencyRegistry {
    struct TokenInfo {
        bytes32 canonicalId; // unique identifier across chains (e.g., hash of chain+address)
        address localAddress; // local token address on this chain
        string symbol;
        string name;
        uint8 decimals;
        bool isStable; // used by router/aggregator
    }

    mapping(address => TokenInfo) public byAddress;
    mapping(bytes32 => TokenInfo) public byCanonical;

    event Registered(bytes32 canonicalId, address localAddress, string symbol, string name, uint8 decimals, bool isStable);

    function registerToken(bytes32 canonicalId, address local, string calldata symbol, string calldata name, uint8 decimals, bool isStable) external {
        TokenInfo memory info = TokenInfo({ canonicalId: canonicalId, localAddress: local, symbol: symbol, name: name, decimals: decimals, isStable: isStable });
        byAddress[local] = info;
        byCanonical[canonicalId] = info;
        emit Registered(canonicalId, local, symbol, name, decimals, isStable);
    }

    function getTokenInfoByAddress(address token) external view returns (TokenInfo memory) {
        return byAddress[token];
    }

    function getTokenInfoByCanonical(bytes32 canonicalId) external view returns (TokenInfo memory) {
        return byCanonical[canonicalId];
    }
}
