use circuit::tower::LazyTower;

global H: u32 = 8;
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
    LazyTower::<H, W_BITS>::lazy_tower_hash_chain(
        level_lengths,
        digest_of_digest,
        top_down_digest,
        root_lv,
        root_level,
        childrens,
        item,
    )
}
