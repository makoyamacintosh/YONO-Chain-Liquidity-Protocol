// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./YonoFactory.sol";
import "./YonoPair.sol";
import "./StableSwapPool.sol";

/**
 * @title YonoRouter (Universal Router single-chain prototype)
 * @dev Router that routes swaps across pairs and pools. For cross-chain swaps, it emits Bridge events.
 * TrustedForwarder compatibility: if the router receives calls via a forwarder, it reads tx.origin or uses _msgSender pattern.
 * For brevity this router uses msg.sender; in production, use OpenZeppelin's Context + minimal forwarder checks.
 */
contract YonoRouter {
    YonoFactory public factory;
    address public feeCollector;

    event CrossChainBridgeCall(address indexed token, address indexed from, uint256 amount, uint256 destChainId, bytes32 destAccount);
    event SwapExecuted(address indexed sender, address[] path, uint256[] amounts);

    constructor(address _factory, address _feeCollector) {
        factory = YonoFactory(_factory);
        feeCollector = _feeCollector;
    }

    // Single-hop swap on a YonoPair (tokenA -> tokenB)
    function swapExactTokensForTokensSingle(address pair, uint256 amountIn, uint256 amountOutMin, address to) public {
        // transfer tokens to pair
        address tokenIn = YonoPair(pair).token0();
        // In a real router we must support selecting which token is in/out based on path. This is simplified:
        ERC20Like(tokenIn).transferFrom(msg.sender, pair, amountIn);
        // call pair.swap: compute amounts offchain, instruct the pair to send out
        // For simplicity we assume caller knows amounts and call pair.swap with amountOutMin
        // This prototype will attempt a swap where token0->token1 with amount1Out = amountOutMin
        YonoPair(pair).swap(0, amountOutMin, to);
        emit SwapExecuted(msg.sender, _singlePath(pair), _toArray(amountIn, amountOutMin));
    }

    // Cross-chain bridge hook: lock tokens and emit event for validators to mint on other chain
    function bridgeLock(address token, uint256 amount, uint256 destChainId, bytes32 destAccount) external {
        ERC20Like(token).transferFrom(msg.sender, address(this), amount);
        // In production we would call BridgeLocker; in this router we simply emit event and keep custody
        emit CrossChainBridgeCall(token, msg.sender, amount, destChainId, destAccount);
    }

    // Helpers to craft path/amount arrays for events (simplified)
    function _singlePath(address pair) internal pure returns (address[] memory p) {
        p = new address[](1);
        p[0] = pair;
    }

    function _toArray(uint256 a, uint256 b) internal pure returns (uint256[] memory arr) {
        arr = new uint256[](2);
        arr[0] = a;
        arr[1] = b;
    }
}

abstract contract ERC20Like {
    function transferFrom(address from, address to, uint256 amount) public virtual;
}
