# Smart Contract & Raffle Concepts

## 1. Contract Structure
A well-structured Solidity contract generally follows this order:
1. **Version pragma** – Specifies Solidity version.
2. **Imports** – Libraries, interfaces, or base contracts needed.
3. **Errors** – Custom error types to save gas and improve clarity.
4. **Interfaces/Libraries/Contracts** – Reusable pieces of code.
5. **Type Declarations** – Enums, structs, etc.
6. **State Variables** – Stored data on-chain.
7. **Events** – Signals emitted for off-chain listeners.
8. **Modifiers** – Reusable function guards.
9. **Functions** – Logic of the contract.

## 2. Function Layout
- **Constructor** – Initializes the contract.
- **Receive / Fallback** – Optional functions for receiving ETH or handling unknown calls.
- **External / Public** – Functions callable from outside the contract.
- **Internal / Private** – Functions for internal logic only.
- **View & Pure** – Read-only functions that do not modify state (view) or even read state (pure).

## 3. Chainlink VRF (Verifiable Random Function)
- Provides **provably random numbers** for smart contracts.
- Ensures fairness (e.g., picking a random raffle winner) without trusting any single party.
- Uses **request → callback** pattern:
  1. Contract requests random words from VRF Coordinator.
  2. VRF Coordinator calls `fulfillRandomWords` with the random value.

## 4. Events & Logging
- **Event** – A way to log important occurrences on-chain.
- **Emit** – Triggers an event, storing it in the blockchain log.
- Useful for front-ends, analytics, and transparency.

## 5. Raffle Mechanics
- Users **enter** by sending ETH ≥ entrance fee.
- Contract keeps a list of players and the **raffle state** (OPEN/CALCULATING).
- Chainlink Keepers monitor:
  - Time interval passed
  - Sufficient players and balance
  - Raffle is open
- If conditions met → **performUpkeep** → request VRF → pick winner.
- Winner receives the prize, state resets for the next round.

## 6. Security & Gas Optimization
- Use **custom errors** instead of `require` strings to save gas.
- Internal/private functions prevent unwanted access.
- Reset dynamic arrays after use to avoid stale data.
- Modular layout improves readability, maintainability, and auditing.

---
