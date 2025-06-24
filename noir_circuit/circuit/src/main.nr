use std::hash::poseidon::bn254::hash_2;

global H: u32 = 10;
global W: u32 = 4;
global W_BITS_U8: u8 = 4;
global W_BITS_U32: u32 = 4;

fn num_2_bits(level_length_array: u32) -> [u32; 4] {
    let mut output = [0; W_BITS_U32];
    let mut lc1 = 0;
    let mut e2 = 1;

    for i in 0..W_BITS_U8 {
        output[i] = (level_length_array >> i) & 1;
        assert(output[i] * (output[i] - 1) == 0);
        lc1 += output[i] * e2;
        e2 = e2 + e2;
    }
    assert(lc1 == level_length_array);
    output
}

// ---------------------------------------------------------------
fn hash_chain<let N: u32>(inputs: [Field; N], len: u32) -> Field {
    let mut outs = [Field::from(0); (N + 1)];
    outs[0] = 0;
    outs[1] = inputs[0];

    for i in 2..(N + 1) {
        outs[i] = hash_2([outs[i - 1], inputs[i - 1]]);
    }
    outs[len]
}

fn is_in_array<let N: u32>(arr: [Field; N], item: Field) -> u32 {
    let mut acc = 1;

    for i in 0..arr.len() {
        acc *= arr[i] - item;
    }

    if acc == 0 {
        1
    } else {
        0
    }
}

fn leading_ones<let N: u32>(len: u32) -> [u32; N] {
    let mut output = [0; N];
    let mut one_count = 0;

    for i in 0..N as u32 {
        if i < len {
            output[i] = 1;
        } else {
            output[i] = 0;
        };
        assert((output[i] - 0) * (output[i] - 1) == 0);
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

unconstrained fn compute_data_height(level_lengths: u32) -> u32 {
    let mut h = 0;
    let mut lvl_len = level_lengths;

    while (level_lengths > 0) {
        h += 1;
        lvl_len >>= W_BITS_U8;
    }
    h
}

unconstrained fn compute_single_level_length(level_lengths: u32, lv: u8) -> u32 {
    let mask = (1 << W_BITS_U8) - 1;
    level_lengths >> (lv * W_BITS_U8) & mask
}

fn compute_data_height_and_level_length_array(level_lengths: u32) -> (u32, [u32; H]) {
    let mut level_length_array = [0; H];
    let data_height = unsafe { compute_data_height(level_lengths) };

    for lv in 0..H {
        let lv_u8 = lv as u8;
        level_length_array[lv] = unsafe { compute_single_level_length(level_lengths, lv_u8) };
    }

    let ones = leading_ones(data_height);
    let mut dummy = [[0; W_BITS_U32]; H];
    let mut s = 0;

    for lv in 0..H {
        dummy[lv] = num_2_bits(level_length_array[lv]);
        assert(level_length_array[lv] < W_BITS_U32);
        assert(level_length_array[lv] != 0);
        assert(ones[lv] == 1);
        s += level_length_array[lv] * (1 << ((lv * W_BITS_U32) as u8)); // 2^(lv * W_BITS_U32)
    }

    assert(level_lengths == s);
    (data_height, level_length_array)
}

fn include_prefix<let N: u32>(inputs: [Field; N], prefix_len: u32, root: Field) -> u32 {
    let leading_ones = leading_ones(prefix_len);
    let mut is_good = [0; N];
    let mut good_count = 0;

    for i in 0..N {
        let result = if inputs[i] == root { 1 } else { 0 };
        is_good[i] = result & leading_ones[i];
        good_count += is_good[i];
    }

    assert(good_count == 1);
    good_count
}

fn check_merkle_proof_and_compute_root(
    childrens: [[Field; W]; H - 1],
    root_lv: u32,
    leaf: Field,
) -> Field {
    let mut TBI = [0; H];
    TBI[0] = leaf;

    let must_include = leading_ones(root_lv);

    for lv in 0..(H - 1) {
        assert((is_in_array(childrens[lv], TBI[lv]) | !must_include[lv]) == 1);
        TBI[lv + 1] = hash_chain(childrens[lv], W_BITS_U32);
    }
    let root = TBI[root_lv];
    root
}

fn main(
    level_lengths: pub u32,
    digest_of_digest: pub Field,
    top_down_digest: pub [Field; H],
    root_lv: pub u32,
    root_level: pub [Field; W],
    childrens: pub [[Field; W]; H - 1],
    item: pub Field,
) {
    assert(level_lengths != 0);
    let (data_height, level_length_array) =
        compute_data_height_and_level_length_array(level_lengths);
    assert(data_height < (1 << 8));
    assert(root_lv < data_height);

    let root_level_length = level_length_array[root_lv];
    assert(root_lv < H);

    assert(hash_chain(top_down_digest, data_height) == digest_of_digest);

    let root_level_digest = top_down_digest[data_height - root_lv - 1];
    assert(hash_chain(root_level, root_level_length) == root_level_digest);

    let root = check_merkle_proof_and_compute_root(childrens, root_lv, item);
    assert(include_prefix(root_level, root_level_length, root) == 1);
}

#[test]
fn test_main() {}
