# Bitcoin Ordinal Inscriber
Bitcoin Ordinal Inscriber is a groundbreaking project that empowers users to inscribe data permanently, backed by Bitcoin, and create ERC721 compatible NFTs for use in all Ethereum Virtual Machine (EVM) chains connected by Zetachain. This protocol opens the door to mirror existing DeFi primitives with Bitcoin, starting with NFTs, enabling users to harness the power of digital gold in a composable and interoperable manner.

<img width="936" alt="Screenshot 2024-01-05 at 15 31 26" src="https://github.com/z3k-ethglobal/zeta-chain-track/assets/82727098/24b25311-10b6-4b18-99a2-9d7910f4dac4">

- **Bitcoin-Backed NFTs**: Create ERC721 compatible NFTs backed by Bitcoin, unlocking new possibilities for DeFi applications.

- **Zetachain Omnipresence**: Leverage Zetachain's innovative omnichain connectivity to seamlessly integrate and utilize Bitcoin-backed financial instruments across various EVM-compatible chains.

# Flow of the project
<img width="1132" alt="Screenshot 2024-01-05 at 15 45 57" src="https://github.com/z3k-ethglobal/zeta-chain-track/assets/82727098/90154091-e39d-4530-9f4f-6a671f0a6799">
- The flow of the project starts with the external chain that has the accessibility of chainlink, uploading the metadata digital file and also most important is the evm compatible.
- The message then sent to initiate the txn in the BTC chain with recipient to be the `TSS address`.
- Then comes into the picture the `Zetachain` and then it sends the data to the other chain to mint the NFT with the metadata that was inscribed in Bitcoin.

## Flow of data from Zetachain
<img width="1061" alt="Screenshot 2024-01-05 at 15 55 53" src="https://github.com/z3k-ethglobal/zeta-chain-track/assets/82727098/d4bf4362-9f7b-4679-9357-d33e552af313">
- Since it is not possible until now to send any data outside zetachain using `Cross-Chain Messaging`.
- We converted the 52-Bytes data to `uint`and then breaked that into 13 parts of 4 bytes and then send that value outside the Zetachain.<br>
- This made the value represent the data and hence a way to send the data outside the zetachain
<br>
<img width="1201" alt="Screenshot 2024-01-05 at 16 24 32" src="https://github.com/z3k-ethglobal/zeta-chain-track/assets/82727098/12f02960-5f18-43d9-a633-a7a59f853e55">

And now that the data is transferred to the other chain, they can mint the NFTs and contact each other with the use of Cross Chain Messaging.


# Hardhat Template for ZetaChain

This is a simple Hardhat template that provides a starting point for developing
smart contract applications on ZetaChain.

## Prerequisites

Before getting started, ensure that you have
[Node.js](https://nodejs.org/en/download) (version 18 or above) and
[Yarn](https://yarnpkg.com/) installed on your system.

## Getting Started

To get started, install the necessary dependencies:

```
yarn
```

## Hardhat Tasks

This template includes Hardhat tasks that streamline smart contract development.
Learn more about the template and the functionality it provides
[in the docs](https://www.zetachain.com/docs/developers/template/).

## Next Steps

To learn more about building decentralized apps on ZetaChain, follow the
tutorials available in
[the introduction to ZetaChain](https://www.zetachain.com/docs/developers/overview/).

