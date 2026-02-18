# Deploy with Foundry using Anvil-zkSync

## 1. Install zkSync Foundry tools

```bash
curl -L https://raw.githubusercontent.com/matter-labs/foundry-zksync/main/install.sh | bash
```

Restart your shell.

## 2. Start local zkSync node

```bash
anvil-zksync
```

Copy one private key from the output.

Local RPC:

```
http://127.0.0.1:8011
```

## 3. Build contracts for zkSync

```bash
forge build --zksync
```

## 4. Deploy contract locally

```bash
forge create src/SimpleStorage.sol:SimpleStorage \
  --rpc-url http://127.0.0.1:8011 \
  --private-key YOUR_PRIVATE_KEY \
  --zksync
```

## 5. Read from contract

```bash
cast call CONTRACT_ADDRESS "retrieve()(uint256)" \
  --rpc-url http://127.0.0.1:8011
```

## 6. Write to contract

```bash
cast send CONTRACT_ADDRESS "store(uint256)" 5 \
  --rpc-url http://127.0.0.1:8011 \
  --private-key YOUR_PRIVATE_KEY
```

## Notes

* Use only test private keys.
* Do not commit `.env`.
* This setup is for local zkSync testing only.

---
