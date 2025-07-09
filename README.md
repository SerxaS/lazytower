# 🧪 LazyTower ZK Proof Demo

This demo walks through generating a `prover.toml` input, executing the Noir circuit, generating a proof using `bb`, writing the verifying key, and verifying the result.


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