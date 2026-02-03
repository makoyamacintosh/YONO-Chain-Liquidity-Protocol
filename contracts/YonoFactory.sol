// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title YonoFactory
 * @dev Factory for creating YonoPair (AMM) pools.
 * For simplicity, this factory deploys YonoPair clones directly (no create2 determinism here).
 */
import "./YonoPair.sol";
import "./StableSwapPool.sol";

contract YonoFactory {
    address public owner;
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    constructor() {
        owner = msg.sender;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "YonoFactory: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "YonoFactory: ZERO_ADDRESS");
        require(getPair[token0][token1] == address(0), "YonoFactory: PAIR_EXISTS");

        YonoPair newPair = new YonoPair(token0, token1);
        pair = address(newPair);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    // create a 4-token StableSwap pool (addresses must be provided)
    event StablePoolCreated(address pool, address[] tokens, uint256 amplification);

    function createStablePool(address[] calldata tokens, uint256 amplification) external returns (address) {
        require(tokens.length >= 2, "YonoFactory: need tokens");
        StableSwapPool pool = new StableSwapPool(tokens, amplification);
        emit StablePoolCreated(address(pool), tokens, amplification);
        return address(pool);
    }
}
