use std::fmt;

#[derive(Debug)]
pub enum TowerError {
    Full,
}

impl fmt::Display for TowerError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            TowerError::Full => write!(f, "The tower is full."),
        }
    }
}

impl std::error::Error for TowerError {}
