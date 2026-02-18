# Deploying with Foundry on zkSync

## Prerequisites

* Linux environment
* Foundry installed and working
* Node.js and npm installed
* A funded zkSync testnet wallet private key
* RPC URL for zkSync testnet

Verify Foundry:

```bash
forge --version
cast --version
anvil --version
```

## Install zkSync Foundry Support

Install the zkSync Foundry toolchain:

```bash
curl -L https://raw.githubusercontent.com/matter-labs/foundry-zksync/main/install.sh | bash
```

Restart your shell and verify:

```bash
forge --version
```

## Create or Use an Existing Foundry Project

Create a new project:

```bash
forge init zk-foundry-project
cd zk-foundry-project
```

Or use your current project directory.

## Configure Environment Variables

Create a `.env` file in the project root:

```bash
touch .env
```

Add the following:

```
PRIVATE_KEY=your_private_key_here
ZKSYNC_RPC_URL=https://sepolia.era.zksync.dev
```

Load variables:

```bash
source .env
```

## Compile Contracts for zkSync

Compile using the zkSync compiler:

```bash
forge build --zksync
```

## Deploy a Contract

Example deployment command:

```bash
forge create src/SimpleStorage.sol:SimpleStorage \
  --rpc-url $ZKSYNC_RPC_URL \
  --private-key $PRIVATE_KEY \
  --zksync
```

After running, the terminal will print:

* Contract address
* Transaction hash
* Deployer address

## Verify Deployment

Check the deployed contract using a call:

```bash
cast call CONTRACT_ADDRESS "retrieve()(uint256)" \
  --rpc-url $ZKSYNC_RPC_URL
```

Replace `CONTRACT_ADDRESS` with the deployed address.

## Common Useful Commands

Rebuild:

```bash
forge build --zksync
```

Run tests (local EVM):

```bash
forge test
```

Format code:

```bash
forge fmt
```

## Security Notes

* Never commit `.env` files.
* Never expose real private keys.
* Use testnet funds only for development.

Add `.env` to `.gitignore`:

```
.env
```
# Simple Guide: Deploying with Foundry (Anvil and zkSync)

## 1. Start Local Blockchain with Anvil

Run:

```bash
anvil
```

This provides:

* Local RPC URL: `http://127.0.0.1:8545`
* Test accounts with private keys
* Free ETH for testing

Copy one private key from the Anvil output.

## 2. Compile Contracts

Inside your project:

```bash
forge build
```

## 3. Deploy to Anvil (Local)

```bash
forge create src/SimpleStorage.sol:SimpleStorage \
  --rpc-url http://127.0.0.1:8545 \
  --private-key YOUR_ANVIL_PRIVATE_KEY
```

Replace `YOUR_ANVIL_PRIVATE_KEY` with a key from Anvil.

## 4. Interact with Deployed Contract (Local)

Read value:

```bash
cast call CONTRACT_ADDRESS "retrieve()(uint256)" \
  --rpc-url http://127.0.0.1:8545
```

Write value:

```bash
cast send CONTRACT_ADDRESS "store(uint256)" 7 \
  --rpc-url http://127.0.0.1:8545 \
  --private-key YOUR_ANVIL_PRIVATE_KEY
```

# Deploying to zkSync Testnet

## 5. Install zkSync Foundry Support

```bash
curl -L https://raw.githubusercontent.com/matter-labs/foundry-zksync/main/install.sh | bash
```

Restart the shell afterward.

## 6. Set Environment Variables

Create `.env`:

```
PRIVATE_KEY=your_testnet_private_key
ZKSYNC_RPC_URL=https://sepolia.era.zksync.dev
```

Load it:

```bash
source .env
```

## 7. Build for zkSync

```bash
forge build --zksync
```

## 8. Deploy to zkSync

```bash
forge create src/SimpleStorage.sol:SimpleStorage \
  --rpc-url $ZKSYNC_RPC_URL \
  --private-key $PRIVATE_KEY \
  --zksync
```

## 9. Verify Deployment

```bash
cast call CONTRACT_ADDRESS "retrieve()(uint256)" \
  --rpc-url $ZKSYNC_RPC_URL
```

# Useful Commands Summary

Build:

```bash
forge build
```

Test:

```bash
forge test
```

Format:

```bash
forge fmt
```

Start local node:

```bash
anvil
```

# Safety Notes

* Use only test private keys.
* Do not commit `.env`.
* Never use real funds during testing.

---


