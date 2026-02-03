// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title YonoPair
 * @dev Simplified UniswapV2-style pair contract implementing x * y = k and LP token behavior.
 * NOTE: This is a concise educational implementation — use audited Uniswap v2 contracts for production.
 */
contract YonoPair {
    string public name = "YONO-LP";
    string public symbol = "YLP";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    address public token0;
    address public token1;

    uint112 private reserve0; // uses single-slot storage packing similar to Uniswap v2
    uint112 private reserve1;
    uint32 private blockTimestampLast;

    uint256 public constant FEE_NUM = 997; // fee: 0.3% -> 997/1000
    uint256 public constant FEE_DEN = 1000;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }

    // simple safe transfer helpers (assume ERC20-like)
    function _safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSignature("transfer(address,uint256)", to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "YonoPair: TRANSFER_FAILED");
    }

    // get reserves
    function getReserves() public view returns (uint112, uint112, uint32) {
        return (reserve0, reserve1, blockTimestampLast);
    }

    // Add liquidity (user must transfer tokens to this contract before calling)
    // This simplified version mints LP tokens proportional to added liquidity.
    function mint(address to) external returns (uint256 liquidity) {
        // read balances
        uint256 balance0 = ERC20Like(token0).balanceOf(address(this));
        uint256 balance1 = ERC20Like(token1).balanceOf(address(this));
        uint256 amount0 = balance0 - reserve0;
        uint256 amount1 = balance1 - reserve1;

        if (totalSupply == 0) {
            liquidity = sqrt(amount0 * amount1) - 1000; // lock minimal liquidity
            totalSupply += 1000;
            balanceOf[address(0)] += 1000;
        } else {
            liquidity = min((amount0 * totalSupply) / reserve0, (amount1 * totalSupply) / reserve1);
        }
        require(liquidity > 0, "YonoPair: INSUFFICIENT_LIQUIDITY_MINTED");
        balanceOf[to] += liquidity;
        totalSupply += liquidity;

        _update(uint112(balance0), uint112(balance1));
        emit Mint(msg.sender, amount0, amount1);
    }

    // Remove liquidity
    function burn(address to) external returns (uint256 amount0, uint256 amount1) {
        uint256 liquidity = balanceOf[address(this)];
        require(liquidity > 0, "YonoPair: NO_LIQUIDITY");
        uint256 _totalSupply = totalSupply;
        amount0 = (liquidity * reserve0) / _totalSupply;
        amount1 = (liquidity * reserve1) / _totalSupply;
        require(amount0 > 0 && amount1 > 0, "YonoPair: INSUFFICIENT_LIQUIDITY_BURNED");
        balanceOf[address(this)] -= liquidity;
        totalSupply -= liquidity;
        _safeTransfer(token0, to, amount0);
        _safeTransfer(token1, to, amount1);
        uint256 balance0 = ERC20Like(token0).balanceOf(address(this));
        uint256 balance1 = ERC20Like(token1).balanceOf(address(this));
        _update(uint112(balance0), uint112(balance1));
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // Swap: amount0Out or amount1Out must be > 0
    function swap(uint256 amount0Out, uint256 amount1Out, address to) external {
        require(amount0Out > 0 || amount1Out > 0, "YonoPair: INSUFFICIENT_OUTPUT_AMOUNT");
        (uint112 _reserve0, uint112 _reserve1,) = getReserves();
        require(amount0Out < _reserve0 && amount1Out < _reserve1, "YonoPair: INSUFFICIENT_LIQUIDITY");

        if (amount0Out > 0) _safeTransfer(token0, to, amount0Out);
        if (amount1Out > 0) _safeTransfer(token1, to, amount1Out);

        uint256 balance0 = ERC20Like(token0).balanceOf(address(this));
        uint256 balance1 = ERC20Like(token1).balanceOf(address(this));

        uint256 amount0In = 0;
        uint256 amount1In = 0;
        if (balance0 > _reserve0 - amount0Out) amount0In = balance0 - (_reserve0 - amount0Out);
        if (balance1 > _reserve1 - amount1Out) amount1In = balance1 - (_reserve1 - amount1Out);
        require(amount0In > 0 || amount1In > 0, "YonoPair: INSUFFICIENT_INPUT_AMOUNT");

        // apply fee
        uint256 balance0Adjusted = (balance0 * FEE_NUM) / FEE_DEN;
        uint256 balance1Adjusted = (balance1 * FEE_NUM) / FEE_DEN;
        require(balance0Adjusted * balance1Adjusted >= uint256(_reserve0) * uint256(_reserve1) * FEE_NUM * FEE_NUM / (FEE_DEN * FEE_DEN), "YonoPair: K");
        _update(uint112(balance0), uint112(balance1));
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // internal update
    function _update(uint112 balance0, uint112 balance1) internal {
        reserve0 = balance0;
        reserve1 = balance1;
        blockTimestampLast = uint32(block.timestamp % 2**32);
        emit Sync(balance0, balance1);
    }

    // helpers
    function min(uint256 a, uint256 b) internal pure returns (uint256) { return a < b ? a : b; }
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) { z = x; x = (y / x + x) / 2; }
        } else if (y != 0) { z = 1; }
    }
}

abstract contract ERC20Like {
    function balanceOf(address owner) public view virtual returns (uint256);
}
