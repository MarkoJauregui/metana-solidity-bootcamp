// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Sanctions is ERC20{


    address private owner; 
    mapping(address => bool) private blackListed;


    event Blacklisted(address indexed target);
    event Whitelisted(address indexed target);

    constructor(string memory name, string memory symbol, address _owner) ERC20(name,symbol){
        owner = _owner;
        _mint(owner, 1000);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function blacklist(address target) public onlyOwner{
        blackListed[target] = true;
        emit Blacklisted(target);
    }

    function whitelist(address target) public onlyOwner{
        blackListed[target] = false;
        emit Whitelisted(target);
    }

    function getIsBlackListed(address target) public view returns(bool){
        return blackListed[target];
    }

    //Here we override the transfer and transferFrom functions so we have the require checks.

    function transfer(address recipient, uint256 amount) public virtual override returns (bool)  {
        require(!blackListed[msg.sender], "Sender is blacklisted");
        require(!blackListed[recipient], "Recipient is blacklisted");
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        require(!blackListed[sender], "Sender is blacklisted");
        require(!blackListed[recipient], "Recipient is blacklisted");
        return super.transferFrom(sender, recipient, amount);
    }
}