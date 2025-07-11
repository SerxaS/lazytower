use circuit::tower::LazyTower;

// - H: Number of levels (tree height).
// - W: Max number of elements per level.
// - W_BITS: Bit-width used to encode each level's length in packed format.
global H: u32 = 20;
global W: u32 = 4;
global W_BITS: u32 = 4;

fn main(
    level_lengths: pub u32,
    digest_of_digest: pub Field,
    top_down_digest: pub [Field; H],
    root_lv: pub u32,
    root_level: pub [Field; W],
    childrens: pub [[Field; W]; H - 1],
    item: pub Field,
) {
    LazyTower::<H, W, W_BITS>::lazy_tower_hash_chain(
        level_lengths,
        digest_of_digest,
        top_down_digest,
        root_lv,
        root_level,
        childrens,
        item,
    )
}
