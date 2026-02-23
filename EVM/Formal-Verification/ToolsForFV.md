# Tools For Formal Verification (FV)

## Halmos
- Open-source symbolic execution for Solidity.
- Best for proving/asserting smart contract invariants and edge cases.
- Write properties as Solidity assertions/invariants, then run Halmos checks.
- Useful early in development to catch logic bugs before audit.

## Certora Prover
- Commercial-grade formal verification for smart contracts.
- Best for protocol-level correctness guarantees against custom rules/specs.
- Write CVL specs (rules, invariants, assumptions), then run Prover on contracts.
- Uses `.spec` file to define rules/specs for F.V.
- Common in DeFi/security-critical systems for high-assurance proofs.

## Typical Usage Flow
- Define security/correctness properties first.
- Model assumptions clearly (roles, ranges, environment behavior).
- Run tool, inspect counterexamples, fix code/spec, iterate.
- Keep specs in CI for regression protection.

## Practical Tips
- Start with small, high-impact invariants.
- Avoid over-constraining assumptions.
- Treat counterexamples as test-case generators.
- Combine FV with fuzzing and audits (not a replacement).
