//! Build support helpers for Lumi Rust core

/// Returns the build timestamp as an ISO 8601 string.
pub fn build_timestamp() -> &'static str {
    option_env!("BUILD_TIMESTAMP").unwrap_or("1970-01-01T00:00:00Z")
}

/// Returns the build profile (debug/release).
pub fn build_profile() -> &'static str {
    option_env!("PROFILE").unwrap_or("unknown")
}
