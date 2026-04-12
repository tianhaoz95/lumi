// mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. Disabled for unit test scaffold to avoid codegen macro issues. */
/// Lumi core library

pub mod build_support;
pub use build_support::*;

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
pub use vector_db::{vector_db_init, upsert_embedding, get_embedding};

mod model_registry;
pub use model_registry::{check_model_ready, compute_sha256, get_download_progress, frb_check_model_ready, frb_get_download_progress, frb_start_background_download};

// Inference module (LiteRT-LM bindings)
mod inference;
pub use inference::{InferenceEngine, frb_load_model};

// Agent module (Rig integration)
mod agent;
pub use agent::LumiAgent;

mod agent_frb;
pub use agent_frb::agent_chat;

// Receipt processing (multimodal OCR pipeline stub)
mod receipt;
pub use receipt::{ReceiptData, process_receipt_image};

mod embeddings;
pub use embeddings::{embed_transaction, embed_transaction_from_summary, embed_text};

mod tools;
pub use tools::{log_transaction, log_transaction_with_pool, get_summary, query_transactions_with_pool};

mod sentinel;
pub use sentinel::{run_sentinel_scan, SentinelReport};

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

    #[test]
    fn check_model_ready_false_when_missing() {
        use std::env;
        let tmp = {
            use std::time::{SystemTime, UNIX_EPOCH};
            let nanos = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_nanos();
            env::temp_dir().join(format!("lumi_models_test_{}_{}", std::process::id(), nanos))
        };
        let _ = std::fs::remove_dir_all(&tmp);
        std::fs::create_dir_all(&tmp).unwrap();
        assert_eq!(check_model_ready(&tmp, "e2b", None).unwrap(), false);
        let _ = std::fs::remove_dir_all(&tmp);
    }

    #[test]
    fn check_model_ready_true_with_valid_hash() {
        use std::env;
        use std::io::Write;
        let tmp = {
            use std::time::{SystemTime, UNIX_EPOCH};
            let nanos = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_nanos();
            env::temp_dir().join(format!("lumi_models_test_{}_{}", std::process::id(), nanos))
        };
        let _ = std::fs::remove_dir_all(&tmp);
        std::fs::create_dir_all(&tmp).unwrap();
        let path = tmp.join("e2b.bin");
        let mut f = std::fs::File::create(&path).unwrap();
        f.write_all(b"dummy-model-content").unwrap();
        // Existence check
        assert_eq!(check_model_ready(&tmp, "e2b", None).unwrap(), true);
        // SHA computation sanity: non-empty
        let sha = compute_sha256(&path).unwrap();
        assert!(!sha.is_empty());
        let _ = std::fs::remove_dir_all(&tmp);
    }

    #[test]
    fn frb_wrappers_respect_env_model_dir_and_progress_stub() {
        use std::env;
        use std::io::Write;
        let tmp = {
            use std::time::{SystemTime, UNIX_EPOCH};
            let nanos = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_nanos();
            env::temp_dir().join(format!("lumi_models_test_frb_{}_{}", std::process::id(), nanos))
        };
        let _ = std::fs::remove_dir_all(&tmp);
        std::fs::create_dir_all(&tmp).unwrap();
        // Point the FRB wrapper to the temp dir
        env::set_var("LUMI_MODEL_DIR", &tmp);

        // Use a unique model id per test to avoid shared-state interference
        let model_id = {
            use std::time::{SystemTime, UNIX_EPOCH};
            let nanos = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_nanos();
            format!("frb_{}_{}", std::process::id(), nanos)
        };

        let path = tmp.join(format!("{}.bin", &model_id));
        let mut f = std::fs::File::create(&path).unwrap();
        f.write_all(b"dummy-model-content").unwrap();

        // frb_check_model_ready should observe the file existence and return true
        assert_eq!(frb_check_model_ready(model_id.clone(), None), true);

        // progress is stubbed to 0.0 for unused model ids
        let prog = frb_get_download_progress(model_id.clone());
        assert_eq!(prog, 0.0f32);

        // Clean up
        let _ = std::fs::remove_dir_all(&tmp);
        // Unset env var to avoid affecting other tests
        env::remove_var("LUMI_MODEL_DIR");
    }

    #[test]
    fn background_download_non_blocking() {
        use std::env;
        use std::time::Duration;
        use std::thread;

        let tmp = {
            use std::time::{SystemTime, UNIX_EPOCH};
            let nanos = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_nanos();
            env::temp_dir().join(format!("lumi_models_bg_test_{}_{}", std::process::id(), nanos))
        };
        let _ = std::fs::remove_dir_all(&tmp);
        std::fs::create_dir_all(&tmp).unwrap();
        env::set_var("LUMI_MODEL_DIR", &tmp);

        // Use a unique model id per test to avoid shared-state interference
        let model_id = {
            use std::time::{SystemTime, UNIX_EPOCH};
            let nanos = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_nanos();
            format!("bg_{}_{}", std::process::id(), nanos)
        };

        // Start a short background download (100ms). Should return immediately.
        assert!(crate::model_registry::start_background_download(&model_id, 100));

        // Immediately check progress (should be present and between 0.0 and 1.0)
        let prog0 = crate::model_registry::frb_get_download_progress(model_id.clone());
        assert!(prog0 >= 0.0 && prog0 <= 1.0, "initial progress in range");

        // Wait for completion
        thread::sleep(Duration::from_millis(300));
        let prog1 = crate::model_registry::frb_get_download_progress(model_id.clone());
        assert!(prog1 >= 0.9999_f32, "progress reached near 1.0");

        // Check model file exists and ready
        assert!(crate::model_registry::frb_check_model_ready(model_id.clone(), None));

        let _ = std::fs::remove_dir_all(&tmp);
        env::remove_var("LUMI_MODEL_DIR");
    }
}
