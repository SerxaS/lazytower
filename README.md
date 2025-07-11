# 🧪 LazyTower ZK Proof Demo

This demo verifies inclusion of an item in a recursive Merkle-like hash-chain using the `LazyTower` circuit.  
It walks through generating a `prover.toml` input, executing the Noir circuit, generating a proof using `bb`, writing the verifying key, and verifying the result.

> ⚠️ **Important:** Make sure the constants `H`, `W`, and `W_BITS` are **identical** in both the JS generator (`js/src/index.ts`, used by `npm run generate:toml`) **and** the Noir example (`example/src/main.nr`).  If they differ, the example circuit will fail.

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
  
➡️ This compiles the circuit and runs the example test defined in “example/src/main.nr”.

---

## 3. Generate proof with `bb`

```bash
cd example
mkdir -p ./target
bb prove -b ../../target/example.json -w ../../target/example.gz -o ./target
```

✅ Output:
- ./target/proof  
- ./target/public_inputs

---

## 4. Write verifying key

```bash
bb write_vk -b ../../target/example.json -o ./target
```

✅ Output:
- ./target/vk

---

## 5. Verify the proof

```bash
bb verify -k ./target/vk -p ./target/proof -i ./target/public_inputs
```

✅ Output:
- Proof verified successfully.

---