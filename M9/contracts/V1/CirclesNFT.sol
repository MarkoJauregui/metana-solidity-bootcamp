// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract CirclesNFT is Initializable, ERC721Upgradeable, OwnableUpgradeable {
    error CirclesNFT__MaxSupplyReached();
    error CirclesNFT_WrongMintingPrice();

    uint256 public s_tokenSupply;
    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant PRICE = 0.01 ether;
    address public stakingContract;

    function initialize() public initializer {
        __ERC721_init("Circles NFT", "o");
        __Ownable_init();
        s_tokenSupply = 0;
    }

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
