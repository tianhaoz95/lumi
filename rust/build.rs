// build.rs for Lumi Rust core
use std::env;
use std::fs;
use std::path::Path;
use std::time::{SystemTime, UNIX_EPOCH};

fn main() {
    // Write build timestamp as env var
    let now = SystemTime::now().duration_since(UNIX_EPOCH).unwrap();
    let timestamp = chrono::Utc::now().to_rfc3339();
    println!("cargo:rustc-env=BUILD_TIMESTAMP={}", timestamp);
    // Pass profile
    let profile = env::var("PROFILE").unwrap_or_else(|_| "unknown".to_string());
    println!("cargo:rustc-env=PROFILE={}", profile);
    // Touch a file to trigger rebuilds if needed
    let out_dir = env::var("OUT_DIR").unwrap();
    let stamp_path = Path::new(&out_dir).join("build.stamp");
    fs::write(stamp_path, timestamp).unwrap();
}
