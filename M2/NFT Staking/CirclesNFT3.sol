// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CirclesNFT3 is ERC721, Ownable {
    // Custom Errors
    error CirclesNFT__MaxSupplyReached();
    error CirclesNFT_WrongMintingPrice();

    // Variables
    uint256 public s_tokenSupply;
    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant PRICE = 0.01 ether;

    // Address of the Staking Contract
    address public stakingContract;

    // Functions
    constructor() ERC721("Circles NFT", "o") {}

    function mint() external payable {
        if (s_tokenSupply >= MAX_SUPPLY) revert CirclesNFT__MaxSupplyReached();
        if (msg.value != PRICE) revert CirclesNFT_WrongMintingPrice();
        _mint(msg.sender, s_tokenSupply);
        s_tokenSupply++;
    }

    function setStakingContract(address _stakingContract) external onlyOwner {
        stakingContract = _stakingContract;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmdpEYwJircF4qH5imJG4bJT3TH6rNYxzCL2d8B4bG7Uhy/";
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}