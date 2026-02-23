# Notes: Bugs and Vulnerabilities (Formal Verification Practice)

## Critical

- Broken overflow guard in `mulWadUp` allows silent overflow and wrong results.
  - File: `src/MathMasters.sol:52`
  - Code uses `gt(x, or(div(not(0), y), x))`.
  - Because `or(div(max, y), x) >= x`, `gt(x, ...)` is always false, so overflow check is effectively disabled.
  - Impact: `mul(x, y)` can wrap and produce incorrect values instead of reverting.

## High

- `mulWadUp` has incorrect state mutation logic causing off-by-one outputs for a large input region.
  - File: `src/MathMasters.sol:56`
  - `if iszero(sub(div(add(z, x), y), 1)) { x := add(x, 1) }` mutates `x` before final computation.
  - With `z` initially zero, this condition becomes true whenever `x / y == 1`, so `x` is incremented unexpectedly.
  - Impact: returns values larger than mathematical `ceil(x * y / WAD)` for some valid inputs.

- Custom error payload encoding is wrong in both `mulWad` and `mulWadUp`.
  - Files: `src/MathMasters.sol:40-41`, `src/MathMasters.sol:53-54`
  - Selector is written with `mstore(0x40, ...)`, but revert uses `revert(0x1c, 0x04)`.
  - This revert range does not point at the stored selector.
  - Impact: callers/tests expecting `MathMasters__MulWadFailed()` selector may not observe it correctly.

## Medium

- `mulWadUp` implementation diverges from standard, auditable pattern and is fragile.
  - File: `src/MathMasters.sol:56-57`
  - Uses extra branch and uninitialized output variable `z` in intermediate logic.
  - Even where outputs happen to match, this raises verification and maintenance risk.

- Suspicious magic number in `sqrt` initialization path.
  - File: `src/MathMasters.sol:77`
  - Comment says correct threshold is `16777215 (0xffffff)`, code uses `16777002`.
  - I did not reproduce a mismatch quickly with sampling, but this should be treated as a likely typo and formally proven.

## Test Suite Gaps / Verification Gaps

- No explicit revert-path assertions for overflow behavior.
  - File: `test/MathMasters.t.sol`
  - Fuzz tests skip overflow cases instead of asserting expected revert/error selector.

- `mulWadUp` fuzz test can miss buggy behavior in overflow branch by design.
  - File: `test/MathMasters.t.sol:34-43`
  - Guard filters out overflow inputs; this hides the broken overflow check in implementation.

- Project currently cannot run tests in this workspace without dependencies.
  - Error observed: missing `forge-std/Test.sol` import.
  - File: `test/Base_Test.t.sol:4`

## Suggested Formal Properties to Prove

- `mulWad(x, y)`:
  - Reverts iff `y != 0 && x > type(uint256).max / y`.
  - Otherwise equals `floor(x * y / 1e18)`.

- `mulWadUp(x, y)`:
  - Reverts under same overflow condition.
  - Otherwise equals `0` when `x == 0 || y == 0`, else `ceil(x * y / 1e18)`.

- `sqrt(x)`:
  - `z * z <= x` and `(z + 1) * (z + 1) > x` for all `x in [0, 2^256 - 1]`.
