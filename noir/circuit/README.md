# 🧩 circuit/

This folder contains the core components of the `LazyTower` recursive hash-chain circuit, implemented in Noir.

---

## Structure

- `lib.nr` – Entry point that exposes the reusable LazyTower API.
- `tower.nr` – Core implementation of the `LazyTower` circuit logic. It verifies inclusion proofs in a multi-level Merkle-like structure using Poseidon hashing.

---

The `LazyTower` circuit is generic over:
- `H`: Number of levels (tree height)
- `W`: Max elements per level
- `W_BITS`: Bit-width used to pack each level length

See the docstring in `tower.nr` for more details on the structure and constraints.