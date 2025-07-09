# 🧾 js/

This folder contains the TypeScript logic used to generate the input for the Noir circuit.

---

## Purpose

- Converts LazyTower input data (e.g. a hash chain) into `prover.toml`.

---

## Files

- `index.ts` – Main entry point for generating `prover.toml`.
- `package.json` – Project dependencies.
- **Output:** Writes `prover.toml` to `../noir/example/prover.toml`.

---