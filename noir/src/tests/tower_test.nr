use crate::circuit::tower::lazy_tower_hash_chain;

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

    lazy_tower_hash_chain(
        level_lengths,
        digest_of_digest,
        top_down_digest,
        root_lv,
        root_level,
        childrens,
        item,
    );
}
