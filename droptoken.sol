// SPDX-License-Identifier: MIT
// www.droptoken.app - Official Website
pragma solidity ^0.8.29;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256); 
}

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract droptoken {
    address public owner;
    event ETHSent(address indexed sender, address[] recipients, uint256[] amounts);
    event TokensDistributed(address indexed sender, address[] recipients, uint256[] amounts, address token);
    event WithdrawETH(address indexed owner, uint256 amount);
    event WithdrawTokens(address indexed owner, address token, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function sendETH(address[] calldata recipients, uint256[] calldata values) external payable {
        require(recipients.length == values.length, "Array mismatch");
        
        uint256 totalSent = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            totalSent += values[i];
            payable(recipients[i]).transfer(values[i]);
        }

        uint256 balance = address(this).balance;
        if (balance > 0) {
            payable(msg.sender).transfer(balance);
        }
        
        emit ETHSent(msg.sender, recipients, values);
    }

    function droptokenapp(IERC20 token, address[] calldata recipients, uint256[] calldata values) external {
        require(recipients.length == values.length, "Array mismatch");
        
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            total += values[i];
        }

        require(token.transferFrom(msg.sender, address(this), total), "Token transfer failed");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(token.transfer(recipients[i], values[i]), "Token drop failed");
        }

        emit TokensDistributed(msg.sender, recipients, values, address(token));
    }

    function withdrawETH(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        payable(owner).transfer(amount);
        emit WithdrawETH(owner, amount);
    }

    function withdrawERC20(IERC20 token, uint256 amount) external onlyOwner {
        require(token.balanceOf(address(this)) >= amount, "Insufficient token balance");
        require(token.transfer(owner, amount), "Token transfer failed");
        emit WithdrawTokens(owner, address(token), amount);
    }

    receive() external payable {}
}
