/// Lumi core library

pub fn crate_version() -> &'static str {
    "0.1.0"
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn version_is_correct() {
        assert_eq!(crate_version(), "0.1.0");
    }
}
