# NFT Concepts Notes

## What is an NFT?

NFT means Non-Fungible Token.

Non-fungible means unique.
One NFT is not meant to be equal to another NFT.

That is different from ERC-20 tokens like ETH or USDC, where one token is the same as another token of the same type.

## What is ERC-721?

ERC-721 is the standard for NFTs on Ethereum.

A standard is just a common set of rules.
Because of this standard, wallets, marketplaces, and apps know how to read and use NFTs.

## Why NFTs are unique

Each NFT has:

- A unique `tokenId`
- An owner
- A metadata link

The `tokenId` identifies the NFT inside the contract.
The metadata describes what that NFT is.

## Ownership in ERC-721

ERC-20 tracks how many tokens a wallet has.

ERC-721 tracks which wallet owns which specific token.

So instead of only asking "how much?", NFT systems also ask "which one?".

## Fungible vs non-fungible

Fungible:
- Every unit is interchangeable
- Example: 1 USDC is the same as any other 1 USDC

Non-fungible:
- Every unit can be different
- Example: NFT #1 can have different art or traits from NFT #2

## What is metadata?

Metadata is the information that describes the NFT.

Usually it includes:

- `name`
- `description`
- `image`
- `attributes`

Example idea:

```json
{
  "name": "Pug #1",
  "description": "A small NFT",
  "image": "ipfs://...",
  "attributes": [
    { "trait_type": "Mood", "value": "Happy" }
  ]
}
```

## What is `tokenURI`?

`tokenURI` is the link to the NFT metadata.

When a wallet or marketplace reads an NFT, it often calls `tokenURI(tokenId)`.
That URI returns the metadata file for that token.

## Why IPFS is used

Images and metadata are usually too expensive to store fully on-chain.

So most NFT projects store files off-chain and keep only the reference on-chain.

IPFS is commonly used because it is content-based storage.
That means the file is identified by its content hash, not by a normal server URL.

This is usually better than storing files on one centralized website.

## Basic NFT flow with IPFS

1. Create the NFT image
2. Upload the image to IPFS
3. Create metadata JSON that points to that image
4. Upload the metadata JSON to IPFS
5. Store the metadata IPFS URI in the NFT contract
6. Mint the NFT

## What minting means

Minting means creating a new token on-chain.

When an NFT is minted:

- A new `tokenId` is created
- Ownership is assigned
- The NFT becomes part of the collection

## What a collection means

A collection is a group of NFTs managed by one smart contract.

Example:
- same contract name
- same symbol
- similar art style
- different token IDs

## Supply

Supply means how many NFTs can exist in that collection.

Small collection:
- fixed and limited number of NFTs

Large collection:
- many NFTs, sometimes up to 10,000 or more

In this project, the max supply is 3.

## Transfer and approval

ERC-721 supports moving NFTs between wallets.

Important functions:

- `ownerOf(tokenId)`: who owns this NFT
- `balanceOf(user)`: how many NFTs this wallet owns
- `approve(address, tokenId)`: allow one address to manage one NFT
- `setApprovalForAll(address, bool)`: allow an operator to manage all NFTs
- `transferFrom(...)`: transfer NFT
- `safeTransferFrom(...)`: transfer NFT safely, especially to contracts

## Why `safeTransferFrom` matters

If you send an NFT to a contract that cannot handle NFTs, it may get stuck.

`safeTransferFrom` checks whether the receiving contract can accept ERC-721 tokens.

## On-chain vs off-chain

On-chain:
- Data lives directly in the smart contract
- More permanent
- More expensive

Off-chain:
- Data lives outside the contract
- Cheaper
- Depends on external storage

Most simple NFT projects use on-chain ownership and off-chain metadata.

## Marketplace idea

Marketplaces like OpenSea usually read:

- contract address
- token ID
- token URI
- metadata

That is how they show the NFT image, name, and traits.

## In this project

This project uses:

- `BasicNFT.sol` for the ERC-721 contract
- `metadata/` for sample metadata files
- `DeployBasicNFT.s.sol` for deployment
- Foundry tests to verify minting and transfers

## Practical note

The current IPFS CIDs are placeholders.
For a real collection, upload your image and metadata to IPFS, then replace the placeholder URIs with the real ones.
