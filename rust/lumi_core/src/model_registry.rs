use std::fs::File;
use std::io::Read;
use std::path::{Path, PathBuf};

use sha2::{Digest, Sha256};

/// Simple model registry and integrity helpers for Lumi.
///
/// Provides:
/// - compute_sha256(path) -> String
/// - check_model_ready(base_dir, model_id, Option<expected_sha256>) -> bool
/// - start_background_download(model_id, duration_ms) -> bool (non-blocking stub)
/// - get_download_progress(model_id) -> f32

use once_cell::sync::Lazy;
use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;

static DOWNLOAD_PROGRESS: Lazy<Arc<Mutex<HashMap<String, f32>>>> = Lazy::new(|| Arc::new(Mutex::new(HashMap::new())));

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

/// Start a non-blocking background "download" stub that updates progress over duration_ms milliseconds.
/// Returns true immediately and spawns a background thread that writes a dummy model file on completion.
pub fn start_background_download(model_id: &str, duration_ms: u64) -> bool {
    let id = model_id.to_string();
    let progress_map = DOWNLOAD_PROGRESS.clone();
    {
        let mut m = progress_map.lock().unwrap();
        m.insert(id.clone(), 0.0);
    }
    // Spawn a thread that updates progress periodically and writes a dummy file at the end.
    thread::spawn(move || {
        let steps = 10u64;
        let sleep_per_step = if duration_ms == 0 { 10 } else { duration_ms / steps };
        for i in 1..=steps {
            thread::sleep(Duration::from_millis(sleep_per_step));
            let mut m = progress_map.lock().unwrap();
            m.insert(id.clone(), (i as f32) / (steps as f32));
        }
        // create dummy file in models_base_dir
        let base = models_base_dir();
        let path = base.join(format!("{}.bin", id));
        let _ = std::fs::create_dir_all(&base);
        let _ = std::fs::write(path, b"dummy-model-content");
    });
    true
}

/// Read progress from shared in-memory progress map. Returns 0.0 if unknown.
pub fn get_download_progress(model_id: &str) -> f32 {
    let m = DOWNLOAD_PROGRESS.lock().unwrap();
    m.get(model_id).copied().unwrap_or(0.0)
}

use directories::ProjectDirs;
use std::env;

fn models_base_dir() -> std::path::PathBuf {
    if let Ok(dir) = env::var("LUMI_MODEL_DIR") {
        return std::path::PathBuf::from(dir);
    }
    if let Some(proj) = ProjectDirs::from("com", "lumi", "Lumi") {
        return proj.data_dir().to_path_buf();
    }
    env::temp_dir()
}

/// FRB-friendly wrapper: check if a model file exists and (optionally) matches expected SHA.
/// This uses LUMI_MODEL_DIR env var if present, else the platform data dir, else temp.
pub fn frb_check_model_ready(model_id: String, expected_sha256: Option<String>) -> bool {
    let base = models_base_dir();
    match check_model_ready(&base, &model_id, expected_sha256.as_deref()) {
        Ok(v) => v,
        Err(_) => false,
    }
}

/// FRB-friendly wrapper for download progress. Reads in-memory progress map.
pub fn frb_get_download_progress(model_id: String) -> f32 {
    get_download_progress(&model_id)
}

/// FRB wrapper to start a background download stub. Duration in ms.
pub fn frb_start_background_download(model_id: String, duration_ms: u64) -> bool {
    start_background_download(&model_id, duration_ms)
}
