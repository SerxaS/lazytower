import fs from "fs";
import { poseidon2 } from "poseidon-lite";
import { LazyTowerHashChainProofBuilder } from "./lazytower-hash-chain-proof-builder";

// Converts bigint or number to string (for TOML).
function bstr(v: bigint | number): string {
  return `"${v.toString()}"`;
}

// Pretty TOML array for a list of values.
function arrayLine(values: (bigint | number)[]) {
  return `[${values.map(bstr).join(", ")}]`;
}

// Format a 2D array of Merkle children for TOML.
function formatChildrenArray(children: (bigint | number)[][]) {
  return children.map(arrayLine).join(",\n");
}

async function main() {
  const H = 10;
  const W = 4;
  const hash = (a: bigint, b: bigint) => poseidon2([a, b]);

  const pb = LazyTowerHashChainProofBuilder(H, W, hash);
  for (let i = 0n; i < 5n; i++) pb.add(i);

  const index = pb.indexOf(3n);
  const proof = pb.build(index); 

  const toml = `
level_lengths = ${proof.levelLengths}
digest_of_digest = "${proof.digestOfDigests}"
top_down_digest = ${arrayLine(proof.topDownDigests)}
root_lv = ${proof.rootLv}
root_level = ${arrayLine(proof.rootLevel)}
childrens = [
${formatChildrenArray(proof.childrens)}
]
item = "${proof.item}"
`.trim();

  fs.writeFileSync("../noir/Prover.toml", toml);
  console.log("prover.toml generated inside noir folder.");
}

main();