// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


//Import Statements

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CirclesNFT2 is ERC721, Ownable {
    //Custom Errors
    error CirclesNFT__MaxSupplyReached();
    error CirclesNFT_WrongMintingPrice();

    // Variables
    uint256 public s_tokenSupply;
    uint256 public constant MAX_SUPPLY = 10;
    
    address public minterContract;

    // Functions
    constructor() ERC721("Circles NFT","o"){
        
    }

    modifier onlyMinterContract() {
        require(msg.sender == minterContract, "Only the minter contract can call this function");
        _;
    }

    function setMinterContract(address _minterContract) external onlyOwner {
        minterContract = _minterContract;
    }

    function mint() external payable onlyMinterContract  {
        if(s_tokenSupply >= MAX_SUPPLY) revert CirclesNFT__MaxSupplyReached();
        _mint(msg.sender, s_tokenSupply);
        s_tokenSupply++;
    }

    function _baseURI() internal pure override returns (string memory){
        return "ipfs://QmdpEYwJircF4qH5imJG4bJT3TH6rNYxzCL2d8B4bG7Uhy/";
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}