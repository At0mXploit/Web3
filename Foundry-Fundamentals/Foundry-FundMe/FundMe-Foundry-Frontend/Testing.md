# Testing

**Testing**
- `setUp()` runs before every test
- `assertEq`, `vm.prank`, `vm.deal`, `vm.expectRevert`, `hoax`
- `forge test --fork-url <RPC>` — forks live network for Chainlink price feed
- `forge coverage` — check test coverage

**Deployment Scripts**
- `vm.startBroadcast / stopBroadcast` — sends real on-chain txs
- `HelperConfig` — swaps Chainlink address per network using `block.chainid`
- Mock price feed deployed automatically on local Anvil network

**Gas Optimization**
- `forge snapshot` — benchmark gas usage
- Cache storage reads in memory inside loops to avoid costly `SLOAD`s
- Use `constant` and `immutable` for state variables that don't change

**Integration Tests**
- Test full end-to-end flow: deploy → fund → withdraw
- Uses `foundry-devops` to grab latest deployed contract address
## Makefile Shortcuts

```makefile
make deploy        # deploy to Sepolia
make test          # run all tests
make snapshot      # gas snapshot
```

## Networks

| Network | Price Feed |
|---|---|
| Sepolia | Chainlink real feed |
| Anvil (local) | Mock contract auto-deployed |
| Mainnet | Chainlink real feed |

---
