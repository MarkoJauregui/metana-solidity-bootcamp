// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Import Statements
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract ERC20TokenSale is ERC20, Ownable, ReentrancyGuard {
    // Custom Errors
    error ERC20TokenSale__SaleHasEnded();
    error ERC20TokenSale__IncorrectMintingPrice();
    error ERC20TokenSale__NoBalanceToWithdraw();
    error ERC20TokenSale__TransferFailed();

    // Variables
    uint256 public constant MAX_SUPPLY = 1000000 * 10**18; //1 million tokens
    uint256 public constant TOKENS_PER_ETHER = 1000 * 10**18; // 1000 tokens per ETH
    uint256 public constant ETHER_TO_WEI = 10**18; // 1 ether in wei



    //Functions
    //----------------------------------
    constructor(string memory name, string memory symbol) ERC20(name, symbol){
        // you can mint a set amount here if wanted, the folliwing line mints 10 thousand tokens to the contract deployer if uncommented.
        _mint(msg.sender, 10000 * 10**18); 
    }


    //Minting function
    /**
     * @dev Trying out different ways of doing require statements, with both Ifs and require.
     */
    function mintTokens() public  payable nonReentrant {
        // require(totalSupply() > MAX_SUPPLY, "Sale has ended");
        // require(msg.value == ETHER_TO_WEI, "Send Exactly 1 ETH to mint tokens");
        if(totalSupply() >= MAX_SUPPLY) revert ERC20TokenSale__SaleHasEnded();
        if(msg.value != ETHER_TO_WEI) revert ERC20TokenSale__IncorrectMintingPrice();

        uint256 tokensToMint = TOKENS_PER_ETHER;

        if(totalSupply() + tokensToMint > MAX_SUPPLY){
          tokensToMint = MAX_SUPPLY - totalSupply();
        }

        _mint(msg.sender, tokensToMint);
    }

    //Withdraw
    function withdraw() external onlyOwner {
      uint256 contractBalance = address(this).balance;

      // require(contractBalance > 0, "No balance to Withdraw");
      if(contractBalance == 0) revert ERC20TokenSale__NoBalanceToWithdraw();

      (bool success, ) = payable(owner()).call{value: contractBalance}("");
      // require(sucess,"Transfer Failed");
      if(!success) revert ERC20TokenSale__TransferFailed();
    }


    // Receive & Fallback
    // This function is used to receive Ether when someone sends it to the contract's address
    receive() external payable {
        mintTokens();
    }

    fallback() external payable{
      revert("Send Ether to the contract's address to mint tokens");
    }
}