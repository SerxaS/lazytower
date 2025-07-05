# 📦 example/

This folder contains the entrypoint for generating and verifying proofs using the LazyTower circuit.

---

## Files

- `main.nr`: Imports the `lazy_tower_hash_chain` logic and drives the proof generation flow.
- `target/`: Output folder for:
  - `proof.json`
  - `vk.json`
  - `public_inputs.json`

---

## Commands

All commands assume you're running from this folder:

```bash
mkdir -p ./target

# Generate proof
bb prove -b ../../target/example.json -w ../../target/example.gz -o ./target

# Write verifying key
bb write_vk -b ../../target/example.json -o ./target

# Verify proof
bb verify -k ./target/vk -p ./target/proof -i ./target/public_inputs
```
