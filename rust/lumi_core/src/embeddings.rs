use sha2::{Sha256, Digest};
use anyhow::Result;

/// Produce a deterministic placeholder embedding vector (length 768) for a transaction.
/// This is a temporary, deterministic embedding generator used until the real
/// LiteRT-LM embedding pipeline is available.
pub fn embed_transaction(vendor: &str, category: &str, amount: f64, date: &str) -> Result<Vec<f32>> {
    // Build a canonical input string
    let input = format!("{}|{}|{}|{}", vendor, category, amount, date);
    // Base sha
    let mut base_hasher = Sha256::new();
    base_hasher.update(input.as_bytes());
    let base = base_hasher.finalize(); // 32 bytes
    let mut out = Vec::with_capacity(768);

    // Expand by hashing base + counter and converting first 4 bytes to f32 in [-1,1]
    for i in 0..768u32 {
        let mut h = Sha256::new();
        h.update(&base);
        h.update(&i.to_le_bytes());
        let d = h.finalize();
        // use first 4 bytes as u32
        let v = u32::from_le_bytes([d[0], d[1], d[2], d[3]]);
        let f = (v as f64) / (u32::MAX as f64);
        // map to [-1.0, 1.0]
        let mapped = (f * 2.0) - 1.0;
        out.push(mapped as f32);
    }

    Ok(out)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn embedding_length_and_determinism() -> Result<(), Box<dyn std::error::Error>> {
        let a = embed_transaction("Test Vendor", "meals", 4.25, "2026-01-02T12:00:00Z")?;
        let b = embed_transaction("Test Vendor", "meals", 4.25, "2026-01-02T12:00:00Z")?;
        assert_eq!(a.len(), 768);
        assert_eq!(a, b);
        Ok(())
    }
}
