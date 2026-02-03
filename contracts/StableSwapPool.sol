// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title StableSwapPool
 * @dev Simplified 4-token Curve-like stable swap implementation with amplification.
 * This implementation is intentionally simplified for clarity. Curve's invariant math is non-trivial.
 */
contract StableSwapPool {
    address[] public tokens;
    uint256 public amplification; // A
    uint256 public totalSupply; // LP tokens
    mapping(address => uint256) public balances;
    mapping(address => uint256) public lpBalance;

    event AddLiquidity(address indexed provider, uint256[] amounts, uint256 lpMinted);
    event RemoveLiquidity(address indexed provider, uint256[] amounts, uint256 lpBurned);
    event Swap(address indexed buyer, address inToken, address outToken, uint256 inAmount, uint256 outAmount);

    constructor(address[] memory _tokens, uint256 _amplification) {
        tokens = _tokens;
        amplification = _amplification;
    }

    function _indexOf(address token) internal view returns (uint256 idx) {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == token) return i;
        }
        revert("StableSwapPool: TOKEN_NOT_IN_POOL");
    }

    // Add liquidity (user must transfer tokens to this contract before calling)
    function addLiquidity(uint256[] calldata amounts) external returns (uint256 lpMinted) {
        require(amounts.length == tokens.length, "StableSwapPool: INVALID_AMOUNTS");
        uint256 D0 = _D();
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 amt = amounts[i];
            if (amt > 0) {
                ERC20Like(tokens[i]).transferFrom(msg.sender, address(this), amt);
                balances[tokens[i]] += amt;
            }
        }
        uint256 D1 = _D();
        if (totalSupply == 0) {
            lpMinted = D1;
        } else {
            lpMinted = (totalSupply * (D1 - D0)) / D0;
        }
        totalSupply += lpMinted;
        lpBalance[msg.sender] += lpMinted;
        emit AddLiquidity(msg.sender, amounts, lpMinted);
    }

    // Simplified D invariant calculator — not exact Curve formula, but demonstrates amplification effect
    function _D() internal view returns (uint256) {
        uint256 S = 0;
        for (uint256 i = 0; i < tokens.length; i++) {
            S += balances[tokens[i]];
        }
        if (S == 0) return 0;
        uint256 D = S;
        // pseudo amplification effect: scale D by A*(n)
        D = (D * amplification * tokens.length) / 100;
        return D;
    }

    // Simple swap implementation: use weighted constant sum + small fee
    function swap(address inToken, address outToken, uint256 inAmount, uint256 minOut) external returns (uint256 outAmount) {
        require(inToken != outToken, "StableSwapPool: SAME_TOKEN");
        uint256 inIdx = _indexOf(inToken);
        uint256 outIdx = _indexOf(outToken);
        ERC20Like(inToken).transferFrom(msg.sender, address(this), inAmount);
        balances[inToken] += inAmount;
        // simple price: outAmount = inAmount * (balance_out / balance_in) * (1 - fee)
        uint256 balanceIn = balances[inToken];
        uint256 balanceOut = balances[outToken];
        require(balanceIn > 0 && balanceOut > 0, "StableSwapPool: EMPTY_BALANCE");
        uint256 feeNumer = 9995; // 0.05% fee
        uint256 feeDen = 10000;
        outAmount = (inAmount * balanceOut * feeNumer) / (balanceIn * feeDen);
        require(outAmount <= balanceOut, "StableSwapPool: INSUFFICIENT_OUT");
        balances[outToken] -= outAmount;
        ERC20Like(outToken).transfer(msg.sender, outAmount);
        emit Swap(msg.sender, inToken, outToken, inAmount, outAmount);
        return outAmount;
    }
}

abstract contract ERC20Like {
    function transferFrom(address from, address to, uint256 amount) public virtual;
    function transfer(address to, uint256 amount) public virtual;
}
