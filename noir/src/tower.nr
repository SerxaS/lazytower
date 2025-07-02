use super::utils::{num_2_bits, pow2};
use std::hash::poseidon::bn254::hash_2;

// len 0:          0
// len 1        in[0]
// len 2:     H(in[0], in[1])
// len 3:   H(H(in[0], in[1]), in[2])
// len 4: H(H(H(in[0], in[1]), in[2]), in[3])
/// Compute hash chain of given length using Poseidon.
pub fn hash_chain<let N: u32>(inputs: [Field; N], len: u32) -> Field {
    let mut outs = [Field::from(0); (N + 1)];
    outs[0] = 0;
    outs[1] = inputs[0];

    for i in 2..(N + 1) {
        outs[i] = hash_2([outs[i - 1], inputs[i - 1]]);
    }
    outs[len]
}

/// Check if `inputs` is in array (returns 1 or 0).
fn include<let W_BITS: u32>(inputs: [Field; W_BITS], item: Field) -> u32 {
    let mut acc = 1;

    for i in 0..inputs.len() {
        acc *= inputs[i] - item;
    }

    if acc == 0 {
        1
    } else {
        0
    }
}

//             (N)(len)
// leading_ones(4)(0) = [0, 0, 0, 0]
// leading_ones(4)(1) = [1, 0, 0, 0]
// leading_ones(4)(2) = [1, 1, 0, 0]
// leading_ones(4)(3) = [1, 1, 1, 0]
// leading_ones(4)(4) = [1, 1, 1, 1]
// leading_ones(4)(5) = fail
/// Return array of N bits with `len` leading ones.
fn leading_ones<let N: u32>(len: u32) -> [u32; N] {
    let mut output = [0; N];
    let mut one_count = 0;

    for i in 0..N {
        if i < len {
            output[i] = 1;
        } else {
            output[i] = 0;
        };
        let val = output[i] as Field;
        assert(val * (val - 1) == 0);
        one_count += output[i];
    }
    assert(one_count == len);

    let mut from_0_to_1 = [0; (N - 1)];
    let mut from_0_to_1_count = 0;

    for i in 0..(N - 1) {
        from_0_to_1[i] = (1 - output[i]) * output[i + 1];
        from_0_to_1_count += from_0_to_1[i];
    }
    assert(from_0_to_1_count == 0);

    output
}

// Is root being included in the first prefix_len elements of inputs[]?
/// Ensure root appears within the first `prefix_len` items.
pub fn include_prefix<let W_BITS: u32>(
    inputs: [Field; W_BITS],
    prefix_len: u32,
    root: Field,
) -> u32 {
    let leading_ones: [u32; W_BITS] = leading_ones(prefix_len);
    let mut is_good = [0; W_BITS];
    let mut good_count = 0;

    for i in 0..W_BITS {
        let result = if inputs[i] == root { 1 } else { 0 };
        is_good[i] = result & leading_ones[i];
        good_count += is_good[i];
    }

    assert(good_count == 1);
    good_count
}

// Computes a Merkle root at root_lv made from childrens[0 .. root_lv - 1][] and leaf.
//
// Each childrens[i] must include the digest of childrens[i - 1] for i = 1 ... root_lv - 1
// childrens[0] must include leaf.
//
// root = digest of childrens[root_lv - 1] if root_lv > 0
// root = leaf if root_lv == 0
/// Verify Merkle proof up to root_lv and return root.
pub fn check_merkle_proof_and_compute_root<let H: u32, let W_BITS: u32>(
    childrens: [[Field; W_BITS]; H - 1],
    root_lv: u32,
    leaf: Field,
) -> Field {
    // TBI: to be included
    //
    // childrens[lv] must include TBI[lv]  for all lv in [0 ... root_lv - 1]
    //
    // TBI[0] = leaf
    // TBI[lv] = digest of children[lv - 1]  for all lv in [1 ... root_lv]
    // TBI[root_lv] is the root
    //
    // For root_lv = 3, H = 5:                                                         mustInclude[]
    //                                  TBI[4]                                        0
    // root_lv =>                       TBI[3] <== digest of childrens[2] ==> *root*  0
    //           childrens[2]  include  TBI[2] <== digest of childrens[1]             1
    //           childrens[1]  include  TBI[1] <== digest of childrens[0]             1
    //           childrens[0]  include  TBI[0] <== *leaf*                             1
    let mut TBI = [0; H];
    TBI[0] = leaf;

    let must_include: [u32; H - 1] = leading_ones(root_lv);

    for lv in 0..(H - 1) {
        let not_must_include = 1 - (must_include[lv] != 0) as u32;
        assert((include(childrens[lv], TBI[lv]) | not_must_include) == 1);

        TBI[lv + 1] = hash_chain(childrens[lv], W_BITS);
    }

    let root = TBI[root_lv];

    root
}

/// Count nonzero level slots in packed level_lengths.
fn compute_data_height<let W_BITS: u32>(mut level_lengths: u32) -> u32 {
    let mut h = 0;
    let mut lvl_len = level_lengths;

    for _ in 0..(32 / W_BITS) {
        let is_nonzero = (lvl_len != 0) as u32;
        h += is_nonzero;
        lvl_len >>= W_BITS as u8;
    }

    h
}

/// Extract W_BITS-wide level length at index lv.
fn compute_single_level_length<let W_BITS: u32>(level_lengths: u32, lv: u8) -> u32 {
    let mask = (1 << W_BITS as u8) - 1;
    level_lengths >> (lv * W_BITS as u8) & mask
}

// The code relies on the following statement:
// If
//   1. levelLengthArray[i] belongs to [1, W] for i in [0, dataHeight - 1], otherwise levelLengthArray[i] = 0
//   2. dataHeight belongs to [0, H - 1]
//   3. the W^i weighted sum of levelLengthArray = levelLengths
//
// , then levelLengthArray[] and dataHeight will be unique.
//
// A very rough analogy would be like in the 10-base system,
// the only sequence matches with 492 could only be the length 3 [2, 9, 4].
/// Parse packed level_lengths into array and data height.
pub fn compute_data_height_and_level_length_array<let H: u32, let W_BITS: u32>(
    level_lengths: u32,
) -> (u32, [u32; H]) {
    let mut level_length_array = [0; H];
    let data_height = compute_data_height::<W_BITS>(level_lengths);

    for lv in 0..H {
        let lv_u8 = lv as u8;
        level_length_array[lv] = compute_single_level_length::<W_BITS>(level_lengths, lv_u8);
    }

    let ones: [u32; H] = leading_ones(data_height);
    let mut dummy = [[0; W_BITS]; H];
    let mut s = 0;

    for lv in 0..H {
        dummy[lv] = num_2_bits(level_length_array[lv]);
        assert(level_length_array[lv] <= W_BITS);
        assert((level_length_array[lv] != 0) == (ones[lv] == 1));
        s += level_length_array[lv] * pow2(lv * W_BITS);
    }

    assert(level_lengths == s);
    (data_height, level_length_array)
}
