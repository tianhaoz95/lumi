/// Lumi core library

/// Simple ping used for FRB smoke test.
pub fn ping() -> String {
    "pong".to_string()
}

pub fn crate_version() -> &'static str {
    "0.1.0"
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use std::path::Path;

    #[test]
    fn version_is_correct() {
        assert_eq!(crate_version(), "0.1.0");
    }

    #[test]
    fn ping_works() {
        assert_eq!(ping(), "pong".to_string());
    }

    #[test]
    fn gitignore_contains_required_entries() {
        // locate repo root .gitignore relative to this crate
        let manifest_dir = env!("CARGO_MANIFEST_DIR");
        let gitignore_path = Path::new(manifest_dir).join("../../.gitignore");
        let s = fs::read_to_string(&gitignore_path).expect("failed to read .gitignore");
        assert!(s.contains("rust/target/") || s.contains("rust/target"), ".gitignore missing rust/target entry");
        assert!(s.contains("build/"), ".gitignore missing build/ entry");
        assert!(s.contains(".env"), ".gitignore missing .env entry");
    }

    #[test]
    fn pubspec_has_required_dependencies() {
        let manifest_dir = env!("CARGO_MANIFEST_DIR");
        let pubspec_path = Path::new(manifest_dir).join("../../pubspec.yaml");
        let s = fs::read_to_string(&pubspec_path).expect("failed to read pubspec.yaml");
        assert!(s.contains("go_router:"), "pubspec missing go_router");
        assert!(s.contains("appwrite:"), "pubspec missing appwrite");
        assert!(s.contains("flutter_riverpod:"), "pubspec missing flutter_riverpod");
        assert!(s.contains("google_fonts:"), "pubspec missing google_fonts");
        assert!(s.contains("material_symbols_icons:"), "pubspec missing material_symbols_icons");
    }
}
