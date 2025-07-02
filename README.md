# 🧪 LazyTower ZK Proof Demo

This guide walks you through how to generate the prover input (`prover.toml`), execute the Noir circuit, generate a proof, and verify it.

---

## 🛠️ Step 1: Generate `prover.toml` input file

```bash
cd js
npm install              # only needed once
npm run generate:toml    # creates ./noir/prover.toml
```

✅ Output:
```
prover.toml generated inside noir folder.
```

---

## 🧮 Step 2: Execute the Noir circuit

```bash
cd ../noir
nargo execute
```

✅ This produces:
- `target/lazytower.gz` – solved witness
- `target/public_inputs` – public inputs
- `target/lazytower.json` – compiled circuit bytecode

---

## 🔐 Step 3: Generate the proof

```bash
bb prove -b ./target/lazytower.json -w ./target/lazytower.gz -o ./target
```

✅ Output:
```
Proof saved to "./target/proof"
```

---

## 🧾 Step 4: Write verifying key (VK)

```bash
bb write_vk -b ./target/lazytower.json -o ./target
```

✅ Output:
```
VK saved to "./target/vk"
```

---

## ✅ Step 5: Verify the proof

```bash
bb verify -k ./target/vk -p ./target/proof
```

✅ Output:
```
Proof verified successfully
```

---

## ⚠️ Important: Keeping `H` and `W_BITS` in Sync

This project uses constants `H` (tower height) and `W_BITS` (width in bits) in both the TypeScript proof generator and the Noir circuit.

If you change `H` or `W_BITS` in the JS/TS code:
- Update them **also** in the Noir circuit:
  - `global H: u32 = ...;`
  - `global W_BITS: u32 = ...;`

They must be the same in both places for proof generation and verification to succeed.

### 📁 Folder structure

```
lazytower/
├── js/              # JavaScript proof generator
├── noir/            # Noir circuit and inputs
│   └── prover.toml  # Auto-generated prover input
```