# 🧪 LazyTower ZK Proof Demo

This demo walks you through how to generate a `prover.toml` input, execute the Noir circuit, generate a proof using `bb`, write the verifying key, and verify the result.

---

## 1. Generate `prover.toml` with JS

```bash
cd js
npm install
npm run generate:toml
```

✅ Output:
```text
prover.toml generated inside noir/example folder.
```

---

## 2. Execute the Noir circuit

```bash
cd ../noir
nargo execute
```

✅ Output:
- target/example.json  
- target/example.gz

---

## 3. Generate proof with `bb`

```bash
cd example
mkdir -p ./target
bb prove -b ../../target/example.json -w ../../target/example.gz -o ./target
```

✅ Output:
- ./target/proof.json  
- ./target/public_inputs.json

---

## 4. Write verifying key

```bash
bb write_vk -b ../../target/example.json -o ./target
```

✅ Output:
- ./target/vk.json

---

## 5. Verify the proof

```bash
bb verify -k ./target/vk -p ./target/proof -i ./target/public_inputs
```

✅ Output:
- Proof verified successfully

---

## ⚠️ Important: Keeping `H` and `W_BITS` in Sync

This project uses constants `H` (tower height) and `W_BITS` (width in bits) in both the TypeScript proof generator and the Noir circuit.

If you change `H` or `W_BITS` in the JS/TS code:
- Update them **also** in the Noir circuit:
  - `global H: u32 = ...;`
  - `global W_BITS: u32 = ...;`

They must be the same in both places for proof generation and verification to succeed.
