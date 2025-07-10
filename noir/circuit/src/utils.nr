//! Utility functions for binary encoding and powers of two.

/// Convert a u32 integer into a binary array of N bits (least significant bit first).
pub fn num_2_bits<let N: u32>(level_length_array: u32) -> [u32; N] {
    let mut output = [0; N];
    let mut lc1 = 0;
    let mut e2 = 1;

    for i in 0..N {
        output[i] = (level_length_array >> (i as u8)) & 1;
        let val = output[i] as Field;
        assert(val * (val - 1) == 0);
        lc1 += output[i] * e2;
        e2 += e2;
    }
    assert(lc1 == level_length_array);
    output
}

/// Compute 2 raised to the power `exp` (i.e. 2^exp).
pub fn pow2(exp: u32) -> u32 {
    let mut result = 1;
    for _ in 0..exp {
        result *= 2;
    }
    result
}
