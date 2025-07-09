import fs from "fs";
import { poseidon2 } from "poseidon-lite";
import { LazyTowerHashChainProofBuilder } from "./lazytower-hash-chain-proof-builder";

// Converts bigint or number to string (for TOML).
function qstr(v: bigint | number): string {
  return `"${v.toString()}"`;
}

// Pretty TOML array for a list of values.
function arrayLine(values: (bigint | number)[]): string {
  return `[${values.map(qstr).join(", ")}]`;
}

// Format a 2D array of Merkle children for TOML.
function formatChildrenArrayQuoted(children: (bigint | number)[][]): string {
  return children.map(arr => `  ${arrayLine(arr)}`).join(",\n");
}

async function main() {
  const H = 8;
  const W = 4;
  const hash = (a: bigint, b: bigint) => poseidon2([a, b]);

  const pb = LazyTowerHashChainProofBuilder(H, W, hash);
  for (let i = 0n; i < 5n; i++) pb.add(i);

  const index = pb.indexOf(3n);
  const proof = pb.build(index); 

  const toml = `
level_lengths = ${qstr(proof.levelLengths)}
digest_of_digest = ${qstr(proof.digestOfDigests)}
top_down_digest = ${arrayLine(proof.topDownDigests)}
root_lv = ${qstr(proof.rootLv)}
root_level = ${arrayLine(proof.rootLevel)}
childrens = [
${formatChildrenArrayQuoted(proof.childrens)}
]
item = ${qstr(proof.item)}
`.trim();

  fs.writeFileSync("../noir/example/Prover.toml", toml);
  console.log("prover.toml generated inside noir/example folder.");
}

main();