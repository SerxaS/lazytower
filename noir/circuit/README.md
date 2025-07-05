# 🧩 circuit/

This folder defines the core `LazyTower` circuit logic used for recursive hashing.

---

## Files

- `lib.nr`: Main reusable circuit module for LazyTower.
- `test.nr`: Tests for the circuit (run with `nargo test` inside `noir/`).
- `utils.nr`: Helper functions used in the circuit, such as:

---

## Notes

- `H` and `W_BITS` are global constants that define the depth and width of the tower.
- This module is imported in `example/main.nr` for proof generation.
- Make sure `H` and `W_BITS` match the JS side used to generate prover inputs.
