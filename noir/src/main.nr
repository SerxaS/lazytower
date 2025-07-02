mod tower;
pub mod utils;

use tower::{
    check_merkle_proof_and_compute_root, compute_data_height_and_level_length_array, hash_chain,
    include_prefix,
};

global H: u32 = 10;
global W_BITS: u32 = 4;

fn main(
    level_lengths: pub u32,
    digest_of_digest: pub Field,
    top_down_digest: pub [Field; H],
    root_lv: pub u32,
    root_level: pub [Field; W_BITS],
    childrens: pub [[Field; W_BITS]; H - 1],
    item: pub Field,
) {
    assert(level_lengths != 0);
    let (data_height, level_length_array) =
        compute_data_height_and_level_length_array::<H, W_BITS>(level_lengths);
    // root_lv < data_height  (where data_height < 2^8).
    assert(data_height < (1 << 8));
    assert(root_lv < data_height);

    let root_level_length = level_length_array[root_lv];
    assert(root_lv < H);

    // The digest of top_down_digest matches digest_of_digest.
    assert(hash_chain(top_down_digest, data_height) == digest_of_digest);

    let root_level_digest = top_down_digest[data_height - root_lv - 1];
    assert(hash_chain(root_level, root_level_length) == root_level_digest);

    // The root is in the prefix of the root_level.
    // The root covers the item.
    let root = check_merkle_proof_and_compute_root(childrens, root_lv, item);
    assert(include_prefix(root_level, root_level_length, root) == 1);
}

#[test]
fn test_lazy_tower_hash_chain() {
    let level_lengths = 17;
    let digest_of_digest =
        2961510082795718370565764606082963141649148245355877322840462878011704136563;
    let top_down_digest = [
        20127075603631019434055928315203707068407414306847615530687456290565086592967,
        4,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
    ];
    let root_lv = 1;
    let root_level =
        [20127075603631019434055928315203707068407414306847615530687456290565086592967, 0, 0, 0];
    let childrens = [
        [0, 1, 2, 3],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
    ];
    let item = 3;

    main(
        level_lengths,
        digest_of_digest,
        top_down_digest,
        root_lv,
        root_level,
        childrens,
        item,
    );
}
