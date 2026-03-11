# AirDropper

A decentralized frontend for airdropping ERC20 tokens to multiple recipients in a single transaction. Built with Next.js, wagmi, and RainbowKit.

---

## What Does This App Do?

AirDropper lets you connect your crypto wallet and send ERC20 tokens to many wallet addresses at once — instead of sending one transaction per person, it batches everything into one. You enter a token address, a list of recipient addresses, and amounts, and the app handles the rest.

Behind the scenes it:
1. Checks how many tokens you've approved the airdrop contract to spend
2. If not enough, asks you to approve
3. Then calls the smart contract which distributes tokens to everyone in one go

---

## Stack 

### Next.js
A React framework for building web apps. Handles routing, server-side rendering, and the overall app structure. This is the foundation the app runs on.
> https://nextjs.org

### React
The JavaScript library for building UI components — buttons, forms, inputs. Next.js is built on top of React.
> https://react.dev

### wagmi
A React library that makes it easy to interact with the Ethereum blockchain. It provides hooks like `useAccount()` (get the connected wallet address), `useChainId()` (get the current network), and `useConfig()`. Think of it as the bridge between your React app and the blockchain.
> https://wagmi.sh

### @wagmi/core
The lower-level version of wagmi — not tied to React. Used for one-time actions like `readContract` (read data from a contract) and `writeContract` (send a transaction). Used inside the form submit handler.
> https://wagmi.sh/core

### viem
A TypeScript library for interacting with Ethereum at a low level — encoding/decoding data, formatting units (e.g. `parseUnits("100", 18)` converts 100 tokens into the raw wei value the blockchain understands). wagmi uses viem under the hood.
> https://viem.sh

### RainbowKit
Provides the "Connect Wallet" button and modal. Handles all the wallet connection logic (MetaMask, WalletConnect, Coinbase Wallet, etc.) so you don't have to build it yourself.
> https://www.rainbowkit.com

### @tanstack/react-query
A data-fetching and caching library. RainbowKit and wagmi require it to manage async blockchain state internally.
> https://tanstack.com/query

### Tailwind CSS
A utility-first CSS framework. Used for styling via class names.
> https://tailwindcss.com

### Anvil (Foundry)
A local Ethereum blockchain for development and testing. Gives you 10 funded test accounts with fake ETH. Part of the Foundry toolkit.
> https://book.getfoundry.sh/anvil

### pnpm
A fast, efficient package manager (alternative to npm/yarn).
> https://pnpm.io

---

## Prerequisites

Make sure you have these installed before starting:

- **Node.js** v18 or later — https://nodejs.org
- **pnpm** — `npm install -g pnpm`
- **Foundry** (for local testing) — https://getfoundry.sh
  
  ```bash
  curl -L https://foundry.paradigm.xyz | bash
  foundryup
  ```
- **MetaMask** browser extension — https://metamask.io
- **WalletConnect Project ID** — free at https://cloud.walletconnect.com

---

## Environment Variables

Create a `.env.local` file in the project root:

```bash
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_project_id_here
```

Get your Project ID free at https://cloud.walletconnect.com — create a project and copy the ID.

---

## Local Development

### 1. Clone and install

```bash
git clone https://github.com/your-username/airdropper.git
cd airdropper
pnpm install
```

### 2. Add environment variables

```bash
echo "NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_id_here" > .env.local
```

### 3. Start the dev server

```bash
pnpm dev
```

Open http://localhost:3000

---

Deployed with Vercel [here](https://air-dropper-ochre.vercel.app/). Add this `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_id_here`.

## Testing Locally with Anvil

Anvil gives you a fake local blockchain with pre-deployed contracts so you can test without spending real money.

### Step 1 — Get the state file

```bash
curl -o tsender-deployed.json https://raw.githubusercontent.com/Cyfrin/tsender-ui/refs/heads/main/tsender-deployed.json
```

### Step 2 — Start Anvil (Terminal 1)

```bash
pnpm anvil
```

Anvil will print 10 test accounts with private keys. You'll need one for MetaMask.

```
Available Accounts
==================
(0) 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)

Private Keys
==================
(0) 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

### Step 3 — Start the frontend (Terminal 2)

```bash
pnpm dev
```

### Step 4 — Configure MetaMask

Add a new network in MetaMask:

| Setting | Value |
|---|---|
| Network Name | Anvil Localhost |
| RPC URL | `http://127.0.0.1:8545` |
| Chain ID | `31337` |
| Currency Symbol | `ETH` |

Import the Anvil test account:
1. MetaMask → click your account icon → **Add account or hardware wallet**
2. **Import account**
3. Paste the private key: `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`

### Step 5 — Use the app

Fill in the form with these test values:

| Field | Value |
|---|---|
| Token Address | `0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512` |
| Recipients | `0x70997970C51812dc3A010C7d01b50e0d17dc79C8` |
| Amounts | `100` |

Click **Send Airdrop**. MetaMask will pop up twice:
1. **Approve** — grants the contract permission to spend your tokens
2. **Confirm** — executes the airdrop

---

## Contract Addresses

| Network | TSender Contract | Chain ID |
|---|---|---|
| Anvil (local) | `0x5FbDB2315678afecb367f032d93F642f64180aa3` | 31337 |
| zkSync Mainnet | Update in `src/constants.ts` | 324 |

Mock ERC20 token on Anvil: `0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512`

---

## Project Structure

```
airdropper/
├── src/
│   ├── app/
│   │   ├── AirDropForm.tsx   # Main form — allowance, approve, airdrop logic
│   │   ├── header.tsx        # Fixed top navigation bar
│   │   ├── layout.tsx        # Root layout wrapping all pages
│   │   ├── page.tsx          # Home page
│   │   ├── providers.tsx     # wagmi + RainbowKit + React Query providers
│   │   └── globals.css       # Global styles
│   ├── constants.ts          # Contract addresses and ABIs
│   └── rainbowKitConfig.tsx  # wagmi/RainbowKit chain config
├── .env.local                # Secret env variables — never commit this
├── tsender-deployed.json     # Anvil blockchain snapshot for local testing
└── package.json
```

---

## How the ERC20 Approval Flow Works

Before a smart contract can transfer tokens on your behalf, you must give it explicit permission. This is a built-in ERC20 security feature.

```
User fills form and clicks Send Airdrop
              ↓
  Read current allowance (readContract)
              ↓
    Allowance < total needed?
       ↓ YES            ↓ NO
  Call approve()    Skip to airdrop
       ↓
  Wait for tx confirmation
       ↓
  Call airdropERC20()
       ↓
  Wait for tx confirmation
       ↓
       ✓ Done — tokens sent
```

---

## Adding a New Network

1. Deploy the TSender contract on your target network
2. Open `src/constants.ts` and add the chain ID and address:

```ts
export const chainsToTsSender = {
  31337: { tsender: "0x5FbDB2315678afecb367f032d93F642f64180aa3" },
  1:     { tsender: "0xYourMainnetAddress" }, // Ethereum mainnet
}
```

3. Open `src/rainbowKitConfig.tsx` and add the chain:

```ts
import { anvil, zksync, mainnet } from "wagmi/chains"

chains: [anvil, zksync, mainnet],
```

---


