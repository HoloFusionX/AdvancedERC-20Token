// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdvancedToken {
    string public name = "Advanced Token";
    string public symbol = "ATK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isFrozen;
    mapping(address => uint256) public lastTransferTimestamp;
    
    address public owner;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Freeze(address indexed account);
    event Unfreeze(address indexed account);
    event TokensLocked(address indexed account, uint256 until);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    constructor(uint256 initialSupply) {
        owner = msg.sender;
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
    }
    
    function transfer(address to, uint256 value) external {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        require(!isFrozen[msg.sender], "Your account is frozen");
        require(block.timestamp >= lastTransferTimestamp[msg.sender] + 10 minutes, "Transfer cooldown");
        
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        lastTransferTimestamp[msg.sender] = block.timestamp;
        emit Transfer(msg.sender, to, value);
    }
    
    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) external {
        require(to != address(0), "Invalid address");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");
        require(!isFrozen[from], "Sender's account is frozen");
        require(block.timestamp >= lastTransferTimestamp[from] + 10 minutes, "Transfer cooldown");
        
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        lastTransferTimestamp[from] = block.timestamp;
        emit Transfer(from, to, value);
    }
    
    function mint(address to, uint256 value) external onlyOwner {
        totalSupply += value;
        balanceOf[to] += value;
        emit Mint(to, value);
    }
    
    function burn(uint256 value) external {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        totalSupply -= value;
        emit Burn(msg.sender, value);
    }
    
    function freezeAccount(address account) external onlyOwner {
        isFrozen[account] = true;
        emit Freeze(account);
    }
    
    function unfreezeAccount(address account) external onlyOwner {
        isFrozen[account] = false;
        emit Unfreeze(account);
    }
    
    function lockTokens(address account, uint256 duration) external onlyOwner {
        isFrozen[account] = true;
        emit TokensLocked(account, block.timestamp + duration);
    }
    
    function unlockTokens(address account) external onlyOwner {
        isFrozen[account] = false;
        emit Unfreeze(account);
    }
    
    function updateName(string memory newName) external onlyOwner {
        name = newName;
    }
    
    function updateSymbol(string memory newSymbol) external onlyOwner {
        symbol = newSymbol;
    }
    
    function updateDecimals(uint8 newDecimals) external onlyOwner {
        decimals = newDecimals;
    }
}
