# Circles NFT with ERC20 token minting

### Here are the steps to make these contracts interact with one another in Remix IDE:

1. Deploy ```ERC20Test.sol``` and `CirclesNFT2.sol`
2. Deploy `Minter.sol` using the addresses in step 1 as parameters.
3. Within the `ERC20Test` approve the tokens using the `Minter` address and the price amount `10000000000000000000`
4. In the `CirclesNFT2`, use the `setMinterContract` function to set the `Minter` address as the spender.
5. Finally, use the `mintNFT` function in the Mint contract and an NFT should have been minted! You can check by using `balanceOf({insert minter address})` on the CirclesNFT contract to check. Or check the owner of tokenId 0 to see the minter address. 