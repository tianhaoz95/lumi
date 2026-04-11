/// Lumi core library

/// Simple ping used for FRB smoke test.
pub fn ping() -> String {
    "pong".to_string()
}

pub fn crate_version() -> &'static str {
    "0.1.0"
}

mod validators;
pub use validators::{validate_email, validate_password, validate_terms};

mod db;
mod vector_db;
pub use db::{db_init, db_init_with_pool};
pub use vector_db::vector_db_init;

// Inference module (LiteRT-LM bindings)
mod inference;
pub use inference::InferenceEngine;

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
        assert!(s.contains(".vscode/mcp.json"), ".gitignore missing .vscode/mcp.json entry");
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

    #[test]
    fn generated_bindings_exist() {
        use std::path::Path;
        let manifest_dir = env!("CARGO_MANIFEST_DIR");
        let binding_path = Path::new(manifest_dir).join("../../lib/shared/bridge/lumi_core_bridge.dart");
        assert!(binding_path.exists(), "Expected generated Dart binding at {}", binding_path.display());
    }

    // New test to verify sqlx + SQLite work by connecting to an in-memory database
    #[tokio::test]
    async fn sqlx_sqlite_memory_connect() -> Result<(), sqlx::Error> {
        // connect to an in-memory SQLite database
        let pool = sqlx::SqlitePool::connect(":memory:").await?;
        let row: (i64,) = sqlx::query_as("SELECT 1 as value").fetch_one(&pool).await?;
        assert_eq!(row.0, 1);
        Ok(())
    }

    #[tokio::test]
    async fn db_init_creates_tables_with_pool() -> Result<(), sqlx::Error> {
        // Use a single pool and call the migration helper that operates on a pool.
        let pool = sqlx::SqlitePool::connect(":memory:").await?;
        // run the initializer
        db_init_with_pool(&pool).await?;
        // query sqlite_master for table existence
        let rows = sqlx::query(
            "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('transactions','mileage_logs','users');"
        )
        .fetch_all(&pool)
        .await?;
        assert_eq!(rows.len(), 3, "Expected 3 tables to be created");
        Ok(())
    }
}
