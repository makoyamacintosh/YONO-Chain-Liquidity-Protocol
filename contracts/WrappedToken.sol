
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title WrappedToken
 * @dev Simplified ERC20 mintable/burnable used for cross-chain wrapped assets like wETH/wBTC.
 * Access control: only factory or owner can mint/burn in this prototype.
 */
contract WrappedToken {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public factory;
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);

    modifier onlyFactory() {
        require(msg.sender == factory || msg.sender == owner, "WrappedToken: forbidden");
        _;
    }

    constructor(string memory _name, string memory _symbol, address _factory) {
        name = _name;
        symbol = _symbol;
        factory = _factory;
        owner = msg.sender;
    }

    function mint(address to, uint256 amount) external onlyFactory {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
    }

    function burn(address from, uint256 amount) external onlyFactory {
        require(balanceOf[from] >= amount, "WrappedToken: balance");
        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit Burn(from, amount);
        emit Transfer(from, address(0), amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "WrappedToken: balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        require(allowed >= amount, "WrappedToken: allowance");
        require(balanceOf[from] >= amount, "WrappedToken: balance");
        allowance[from][msg.sender] = allowed - amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
}
