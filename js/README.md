# 🧾 js/

This folder contains the TypeScript logic to generate the input for the Noir circuit.

---

## Purpose

- Converts LazyTower input data (e.g. a hash chain) into `prover.toml`
- Ensures `H` and `W_BITS` match the Noir circuit logic

---

## Files

- `index.ts`: Main entrypoint to generate `prover.toml`
- `package.json`: Project dependencies
- Output: Writes `prover.toml` to `../noir/example/prover.toml`

---

## Usage

```bash
cd js
npm install
npm run generate:toml
```

✅ Output:
```text
prover.toml generated inside noir/example folder.
```

Make sure to keep constants `H` and `W_BITS` in sync with the circuit (`noir/circuit/src/lib.nr`).
