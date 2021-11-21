# Platzi Punks from Intro to Dapps @ platzi.com using Chainlink VRF

ERC721 compliant NFT's dapp, that mints avatars based on [avataars.com](https://getavataaars.com/), using Chainlink VRF  (Verifiable Random Function) to get a random number to generate the NFT DNA.

## Live on Rinkeby testnet

Check the collection at OpenSea: https://testnets.opensea.io/collection/platzipunks-mrs9opr93k

Or check the contract at Etherscan: https://rinkeby.etherscan.io/address/0x5A7d9DB2F538AA87b80757c70c644103Fe8B6100

NOTE: After successful mint, wait a few minutes and reload the data on OpenSea or the NFT display app of your choice, on first instance the NFT is minted with a default URI until response is received from Chainlink's oracle.

For more information on Chainlink VRF, visit their [docs](https://docs.chain.link/docs/chainlink-vrf/)
## Tech stack
* Solidity
* Hardhat
* OpenZeppelin smart contract's
* Mocha/Chai and Ethers/Waffle
* Chainlink