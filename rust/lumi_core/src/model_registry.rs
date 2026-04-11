use std::fs::File;
use std::io::Read;
use std::path::{Path, PathBuf};

use sha2::{Digest, Sha256};

/// Simple model registry and integrity helpers for Lumi.
///
/// Provides:
/// - compute_sha256(path) -> String
/// - check_model_ready(base_dir, model_id, Option<expected_sha256>) -> bool
/// - get_download_progress(model_id) -> f32  (stub)

pub struct ModelRegistry {
    pub base_dir: PathBuf,
}

impl ModelRegistry {
    pub fn new<P: Into<PathBuf>>(base_dir: P) -> Self {
        Self { base_dir: base_dir.into() }
    }

    pub fn model_path(&self, model_id: &str) -> PathBuf {
        self.base_dir.join(format!("{}.bin", model_id))
    }
}

pub fn compute_sha256(path: &Path) -> std::io::Result<String> {
    let mut f = File::open(path)?;
    let mut hasher = Sha256::new();
    let mut buf = [0u8; 8192];
    loop {
        let n = f.read(&mut buf)?;
        if n == 0 { break; }
        hasher.update(&buf[..n]);
    }
    Ok(hex::encode(hasher.finalize()))
}

pub fn check_model_ready(base_dir: &Path, model_id: &str, expected_sha256: Option<&str>) -> std::io::Result<bool> {
    let path = base_dir.join(format!("{}.bin", model_id));
    if !path.exists() {
        return Ok(false);
    }
    if let Some(expected) = expected_sha256 {
        let actual = compute_sha256(&path)?;
        Ok(actual == expected)
    } else {
        Ok(true)
    }
}

/// Stubbed progress: real download implementation updates progress via shared state or a file.
pub fn get_download_progress(_model_id: &str) -> f32 {
    0.0
}
