// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20Test.sol";
import "./CirclesNFT2.sol";

contract Minter {
    ERC20Test private erc20Token;
    CirclesNFT private circlesNft;
    uint256 private price;

    constructor(address erc20Address, address erc721Address){
        erc20Token = ERC20Test(erc20Address);
        circlesNft = CirclesNFT(erc721Address);
        price = 10 * (10 ** uint256(erc20Token.decimals()));
    }

    function mintNFT() external {
        require(erc20Token.allowance(msg.sender, address(this)) >= price, "Minter: Not enough allowance");
        erc20Token.transferFrom(msg.sender, address(this), price);
        circlesNft.mint();
    }
}