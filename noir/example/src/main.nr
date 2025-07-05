use lazytower::{H, lazy_tower_hash_chain, W_BITS};

fn main(
    level_lengths: pub u32,
    digest_of_digest: pub Field,
    top_down_digest: pub [Field; H],
    root_lv: pub u32,
    root_level: pub [Field; lazytower::W_BITS],
    childrens: pub [[Field; W_BITS]; H - 1],
    item: pub Field,
) {
    lazy_tower_hash_chain(
        level_lengths,
        digest_of_digest,
        top_down_digest,
        root_lv,
        root_level,
        childrens,
        item,
    )
}
