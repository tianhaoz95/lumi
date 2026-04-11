//! litert-lm - Minimal local stub for LiteRT-LM bindings used during development tests

use serde::{Serialize, Deserialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct LiteRtSession;

#[derive(Debug, Serialize, Deserialize)]
pub enum ModelId {
    E2B,
    E4B,
}

/// Simulate loading a model. Returns a lightweight session handle.
pub fn load_model(_path: &str) -> Result<LiteRtSession, String> {
    Ok(LiteRtSession)
}
