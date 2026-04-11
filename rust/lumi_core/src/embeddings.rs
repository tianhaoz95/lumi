use sha2::{Sha256, Digest};
use anyhow::Result;
use chrono::{TimeZone, Utc};

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

/// Convenience wrapper: embed from a TransactionSummary struct.
/// Builds the canonical string "{vendor} {category} {amount} {date}" where date is RFC3339.
pub fn embed_transaction_from_summary(tx: &crate::tools::TransactionSummary) -> Result<Vec<f32>> {
    let vendor = tx.vendor.as_deref().unwrap_or("");
    let category = tx.category.as_deref().unwrap_or("");
    let amount = tx.amount;
    let date = Utc.timestamp_opt(tx.timestamp, 0)
        .single()
        .map(|d| d.format("%Y-%m-%dT%H:%M:%SZ").to_string())
        .unwrap_or_else(|| "".to_string());
    embed_transaction(vendor, category, amount, &date)
}

/// Produce a deterministic placeholder embedding vector (length 768) for arbitrary text.
/// Mirrors the approach used for transactions so unit tests can run without model deps.
pub fn embed_text(text: &str) -> Result<Vec<f32>> {
    // Use the text itself as the canonical input
    let mut hasher = Sha256::new();
    hasher.update(text.as_bytes());
    let base = hasher.finalize();
    let mut out = Vec::with_capacity(768);
    for i in 0..768u32 {
        let mut h = Sha256::new();
        h.update(&base);
        h.update(&i.to_le_bytes());
        let d = h.finalize();
        let v = u32::from_le_bytes([d[0], d[1], d[2], d[3]]);
        let f = (v as f64) / (u32::MAX as f64);
        let mapped = (f * 2.0) - 1.0;
        out.push(mapped as f32);
    }
    Ok(out)
}

pub use crate::vector_db::upsert_embedding;

#[cfg(test)]
mod tests {
    use super::*;
    use crate::tools::TransactionSummary;
    use chrono::DateTime;

    #[test]
    fn embedding_length_and_determinism() -> Result<(), Box<dyn std::error::Error>> {
        let a = embed_transaction("Test Vendor", "meals", 4.25, "2026-01-02T12:00:00Z")?;
        let b = embed_transaction("Test Vendor", "meals", 4.25, "2026-01-02T12:00:00Z")?;
        assert_eq!(a.len(), 768);
        assert_eq!(a, b);

        let t1 = embed_text("coffee shop")?;
        let t2 = embed_text("coffee shop")?;
        assert_eq!(t1.len(), 768);
        assert_eq!(t1, t2);

        // Test wrapper that consumes TransactionSummary
        let ts = DateTime::parse_from_rfc3339("2026-01-02T12:00:00Z")?;
        let summary = TransactionSummary {
            id: "id".to_string(),
            vendor: Some("Test Vendor".to_string()),
            amount: 4.25,
            currency: "USD".to_string(),
            category: Some("meals".to_string()),
            timestamp: ts.timestamp(),
            is_tagged: false,
        };

        let e1 = embed_transaction_from_summary(&summary)?;
        let e2 = embed_transaction("Test Vendor", "meals", 4.25, "2026-01-02T12:00:00Z")?;
        assert_eq!(e1, e2);

        Ok(())
    }
}
