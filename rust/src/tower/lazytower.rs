#![allow(non_snake_case)]

use ark_ff::Field;

use crate::{
    poseidon_hash::sponge::{self, PoseidonSponge},
    tower::error::TowerError,
};

struct LazyTower<F: Field> {
    H: usize,
    W: usize,
    levels: Vec<Vec<F>>,
    full_levels: Vec<Vec<F>>,
}

impl<F: Field> LazyTower<F> {
    fn new(H: usize, W: usize) -> Self {
        Self {
            H,
            W,
            levels: Vec::new(),
            full_levels: Vec::new(),
        }
    }
    fn poseidon(a: F, b: F) -> F {
        let mut sponge = sponge::PoseidonSponge::new();
        sponge.update(&[a, b]);
        PoseidonSponge::squeeze(&mut sponge)
    }

    fn digestfunc(&self, arr: &[F]) -> F {
        arr.iter()
            .cloned()
            .reduce(|a, b| Self::poseidon(a, b))
            .unwrap()
    }

    fn add(&mut self, lv: usize, item: F) -> Result<(), TowerError> {
        if lv == self.H {
            return Err(TowerError::Full);
        }

        if lv == self.levels.len() {
            self.full_levels.push(vec![item]);
            self.levels.push(vec![item]);
        } else if self.levels[lv].len() < self.W {
            self.full_levels[lv].push(item);
            self.levels[lv].push(item)
        } else {
            self.full_levels[lv].push(item);
            let digest = self.digestfunc(&self.levels[lv]);
            Self::add(self, lv + 1, digest)?;
            self.levels[lv] = vec![item];
        }

        Ok(())
    }
}

#[cfg(test)]
mod test {
    use ark_ff::UniformRand;
    use rand::thread_rng;

    use crate::tower::lazytower::LazyTower;

    #[test]
    fn test() {
        type F = ark_bn254::Fr;

        let H = 10;
        let W = 4;

        let mut tower = LazyTower::<F>::new(H, W);
        let mut rng = thread_rng();

        for _ in 0..5 {
            tower.add(0, F::rand(&mut rng)).unwrap();
        }

        println!("full_levels:{:#?}", tower.full_levels);
        println!("levels:{:#?}", tower.levels);
    }
}
