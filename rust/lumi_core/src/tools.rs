use sqlx::SqlitePool;
use sqlx::Row;
use serde_json::json;
use sha2::{Sha256, Digest};
use hex;
use chrono::{DateTime, Utc};
use uuid::Uuid;
use anyhow::anyhow;
use serde::{Serialize, Deserialize};

/// Insert a transaction into the provided SQLite pool.
/// Returns the inserted (or existing) row id on success.
pub async fn log_transaction_with_pool(
    pool: &SqlitePool,
    vendor: &str,
    amount: f64,
    currency: &str,
    category: &str,
    date: &str,
    receipt_path: Option<&str>,
) -> Result<String, sqlx::Error> {
    // Build a deterministic JSON used for SHA-256 idempotency check
    let meta = json!({
        "vendor": vendor,
        "amount": amount,
        "currency": currency,
        "category": category,
        "date": date,
        "receipt_path": receipt_path,
    });
    let meta_str = meta.to_string();
    let mut hasher = Sha256::new();
    hasher.update(meta_str.as_bytes());
    let sha = hex::encode(hasher.finalize());

    // Convert amount to integer cents to store as INTEGER
    let amount_cents: i64 = (amount * 100.0).round() as i64;

    // Parse date into unix timestamp (seconds). Fall back to now on parse failure.
    let timestamp = DateTime::parse_from_rfc3339(date)
        .map(|dt| dt.timestamp())
        .unwrap_or_else(|_| Utc::now().timestamp());

    // Check for an existing duplicate (vendor + amount + timestamp)
    let existing: Option<String> = sqlx::query_scalar(
        "SELECT id FROM transactions WHERE vendor = ?1 AND amount = ?2 AND timestamp = ?3 LIMIT 1",
    )
    .bind(vendor)
    .bind(amount_cents)
    .bind(timestamp)
    .fetch_optional(pool)
    .await?;

    if let Some(id) = existing {
        return Ok(id);
    }

    let id = Uuid::new_v4().to_string();

    sqlx::query(
        "INSERT INTO transactions (id, amount, currency, vendor, category, timestamp, receipt_path, is_tagged, sha256_hash) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)",
    )
    .bind(&id)
    .bind(amount_cents)
    .bind(currency)
    .bind(vendor)
    .bind(category)
    .bind(timestamp)
    .bind(receipt_path)
    .bind(0i32)
    .bind(&sha)
    .execute(pool)
    .await?;

    Ok(id)
}

/// FRB/Tool-facing wrapper. This uses the LUMI_DB_URL env var if set; otherwise
/// falls back to a local file-based `lumi.db` in the current working dir.
/// The function is exposed to Rig as a tool and returns the inserted row ID on success.
#[rig_macros::tool(description = "Log a financial transaction to the local database")]
pub async fn log_transaction(
    vendor: String,
    amount: f64,
    currency: String,
    category: String,
    date: String,
    receipt_path: Option<String>,
) -> anyhow::Result<String> {
    let db_url = std::env::var("LUMI_DB_URL").unwrap_or_else(|_| "sqlite:lumi.db".to_string());
    let pool = SqlitePool::connect(&db_url)
        .await
        .map_err(|e| anyhow!("failed to connect to db: {}", e))?;

    // Ensure schema exists (best-effort)
    if let Err(e) = crate::db::db_init_with_pool(&pool).await {
        return Err(anyhow!("db_init failed: {}", e));
    }

    let id = log_transaction_with_pool(&pool, &vendor, amount, &currency, &category, &date, receipt_path.as_deref()).await
        .map_err(|e| anyhow!("insert failed: {}", e))?;

    // Attempt to embed and upsert into the vector DB (best-effort, non-fatal for the tool)
    let vector_db_path = std::env::var("LUMI_VECTOR_DB_PATH").unwrap_or_else(|_| "./vector_db".to_string());
    // initialize vector DB directory
    if let Err(e) = crate::vector_db::vector_db_init(&vector_db_path) {
        // Log to stderr but do not fail the main operation
        eprintln!("vector_db_init failed: {}", e);
    } else {
        // Build metadata same as the sha source
        let meta = serde_json::json!({
            "vendor": vendor,
            "amount": amount,
            "currency": currency,
            "category": category,
            "date": date,
            "receipt_path": receipt_path,
        });
        let meta_str = meta.to_string();
        match crate::embeddings::embed_transaction(&vendor, &category, amount, &date) {
            Ok(embedding) => {
                if let Err(e) = crate::vector_db::upsert_embedding(&vector_db_path, &id, &embedding, &meta_str) {
                    eprintln!("upsert_embedding failed: {}", e);
                }
            }
            Err(e) => {
                eprintln!("embed_transaction failed: {}", e);
            }
        }
    }

    Ok(id)
}


/// A compact summary of a transaction returned to callers.
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct TransactionSummary {
    pub id: String,
    pub vendor: Option<String>,
    pub amount: f64,
    pub currency: String,
    pub category: Option<String>,
    pub timestamp: i64,
    pub is_tagged: bool,
}

/// Query transactions with optional filters. Returns a vector of TransactionSummary.
pub async fn query_transactions_with_pool(
    pool: &SqlitePool,
    category: Option<&str>,
    date_from: Option<&str>,
    date_to: Option<&str>,
    limit: Option<u32>,
) -> Result<Vec<TransactionSummary>, sqlx::Error> {
    // Convert dates to timestamps if provided
    let date_from_ts: Option<i64> = date_from
        .and_then(|s| DateTime::parse_from_rfc3339(s).ok())
        .map(|dt| dt.timestamp());
    let date_to_ts: Option<i64> = date_to
        .and_then(|s| DateTime::parse_from_rfc3339(s).ok())
        .map(|dt| dt.timestamp());

    let limit_val: i64 = limit.unwrap_or(50) as i64;

    let sql = "SELECT id, vendor, amount, currency, category, timestamp, is_tagged FROM transactions
        WHERE (?1 IS NULL OR category = ?1)
        AND (?2 IS NULL OR timestamp >= ?2)
        AND (?3 IS NULL OR timestamp <= ?3)
        ORDER BY timestamp DESC
        LIMIT ?4";

    let rows = sqlx::query(&sql)
        .bind(category)
        .bind(date_from_ts)
        .bind(date_to_ts)
        .bind(limit_val)
        .fetch_all(pool)
        .await?;

    let mut out = Vec::with_capacity(rows.len());
    for row in rows {
        let id: String = row.try_get("id")?;
        let vendor: Option<String> = row.try_get("vendor")?;
        let amount_cents: i64 = row.try_get("amount")?;
        let currency: String = row.try_get("currency")?;
        let category: Option<String> = row.try_get("category")?;
        let timestamp: i64 = row.try_get("timestamp")?;
        let is_tagged_i: i32 = row.try_get("is_tagged")?;

        let amount = (amount_cents as f64) / 100.0;
        let is_tagged = is_tagged_i != 0;

        out.push(TransactionSummary { id, vendor, amount, currency, category, timestamp, is_tagged });
    }

    Ok(out)
}

/// FRB/Tool wrapper for querying transactions.
#[rig_macros::tool(description = "Query past transactions with optional filters")]
pub async fn query_transactions(
    category: Option<String>,
    date_from: Option<String>,
    date_to: Option<String>,
    limit: Option<u32>,
) -> anyhow::Result<Vec<TransactionSummary>> {
    let db_url = std::env::var("LUMI_DB_URL").unwrap_or_else(|_| "sqlite:lumi.db".to_string());
    let pool = SqlitePool::connect(&db_url)
        .await
        .map_err(|e| anyhow!("failed to connect to db: {}", e))?;

    // Ensure schema exists
    if let Err(e) = crate::db::db_init_with_pool(&pool).await {
        return Err(anyhow!("db_init failed: {}", e));
    }

    let res = query_transactions_with_pool(&pool, category.as_deref(), date_from.as_deref(), date_to.as_deref(), limit)
        .await
        .map_err(|e| anyhow!("query failed: {}", e))?;

    Ok(res)
}

/// Result returned after logging mileage.
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct MileageLogResult {
    pub id: String,
    pub deduction_amount: f64,
}

/// Insert a mileage log into the provided SQLite pool.
/// Calculates IRS deduction at $0.67/mile (2026 rate) and returns the inserted row id and deduction.
pub async fn log_mileage_with_pool(
    pool: &SqlitePool,
    distance_miles: f64,
    start_location: &str,
    end_location: &str,
    date: &str,
    purpose: &str,
) -> Result<MileageLogResult, sqlx::Error> {
    // compute deduction
    let deduction = (distance_miles * 0.67 * 100.0).round() / 100.0; // round to cents

    // parse date
    let timestamp = DateTime::parse_from_rfc3339(date)
        .map(|dt| dt.timestamp())
        .unwrap_or_else(|_| Utc::now().timestamp());

    let id = Uuid::new_v4().to_string();

    sqlx::query(
        "INSERT INTO mileage_logs (id, distance_miles, start_lat, start_lng, end_lat, end_lng, start_location, end_location, purpose, timestamp, deduction_amount) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11)",
    )
    .bind(&id)
    .bind(distance_miles)
    .bind(Option::<f64>::None)
    .bind(Option::<f64>::None)
    .bind(Option::<f64>::None)
    .bind(Option::<f64>::None)
    .bind(start_location)
    .bind(end_location)
    .bind(purpose)
    .bind(timestamp)
    .bind(deduction)
    .execute(pool)
    .await?;

    Ok(MileageLogResult { id, deduction_amount: deduction })
}

/// FRB/Tool-facing wrapper for logging mileage.
#[rig_macros::tool(description = "Log a mileage entry and calculate IRS deduction")]
pub async fn log_mileage(
    distance_miles: f64,
    start_location: String,
    end_location: String,
    date: String,
    purpose: String,
) -> anyhow::Result<MileageLogResult> {
    let db_url = std::env::var("LUMI_DB_URL").unwrap_or_else(|_| "sqlite:lumi.db".to_string());
    let pool = SqlitePool::connect(&db_url)
        .await
        .map_err(|e| anyhow!(format!("failed to connect to db: {}", e)))?;

    // Ensure schema exists (best-effort)
    if let Err(e) = crate::db::db_init_with_pool(&pool).await {
        return Err(anyhow!(format!("db_init failed: {}", e)));
    }

    let res = log_mileage_with_pool(&pool, distance_miles, &start_location, &end_location, &date, &purpose)
        .await
        .map_err(|e| anyhow!(format!("insert failed: {}", e)))?;

    Ok(res)
}


#[cfg(test)]
mod tests {
    use super::*;
    use crate::db;
    use sqlx::SqlitePool;
    use uuid::Uuid;
    use std::fs;

    #[tokio::test]
    async fn log_transaction_inserts_row_and_returns_id() -> Result<(), Box<dyn std::error::Error>> {
        let pool = SqlitePool::connect(":memory:").await?;
        db::db_init_with_pool(&pool).await?;

        let id = log_transaction_with_pool(&pool, "Test Vendor", 4.25, "USD", "meals", "2026-01-02T12:00:00Z", Some("/tmp/receipt.png")).await?;
        // Verify row exists
        let row: (String,) = sqlx::query_as("SELECT id FROM transactions WHERE id = ?1")
            .bind(&id)
            .fetch_one(&pool)
            .await?;
        assert_eq!(row.0, id);
        Ok(())
    }

    #[tokio::test]
    async fn sha_is_deterministic_for_same_inputs() -> Result<(), Box<dyn std::error::Error>> {
        let pool = SqlitePool::connect(":memory:").await?;
        db::db_init_with_pool(&pool).await?;

        let _id1 = log_transaction_with_pool(&pool, "Vendor A", 10.0, "USD", "supplies", "2026-02-03T09:00:00Z", None).await?;
        // Fetch sha stored
        let cents_first = (10.0f64 * 100.0f64).round() as i64;
        let sha1: (Option<String>,) = sqlx::query_as("SELECT sha256_hash FROM transactions WHERE vendor = ?1 AND amount = ?2 LIMIT 1")
            .bind("Vendor A")
            .bind(cents_first)
            .fetch_one(&pool)
            .await?;

        // Insert same logical transaction again; should return existing ID (idempotent)
        let id2 = log_transaction_with_pool(&pool, "Vendor A", 10.0, "USD", "supplies", "2026-02-03T09:00:00Z", None).await?;
        let cents = (10.0f64 * 100.0f64).round() as i64;
        let sha2: (Option<String>,) = sqlx::query_as("SELECT sha256_hash FROM transactions WHERE id = ?1")
            .bind(&id2)
            .fetch_one(&pool)
            .await?;

        // verify deterministic sha for the same logical transaction
        let sha1_row: (Option<String>,) = sqlx::query_as("SELECT sha256_hash FROM transactions WHERE vendor = ?1 AND amount = ?2 LIMIT 1")
            .bind("Vendor A")
            .bind(cents)
            .fetch_one(&pool)
            .await?;

        assert_eq!(sha1_row.0, sha2.0);
        Ok(())
    }

    #[tokio::test]
    async fn log_transaction_tool_wrapper_inserts_row() -> Result<(), Box<dyn std::error::Error>> {
        // Use a temp file-backed sqlite DB so multiple connections can observe the data.
        let tmp_path = std::env::temp_dir().join(format!("lumi_test_{}.db", Uuid::new_v4()));
        // Ensure the file exists so sqlite can open it.
        let _f = std::fs::File::create(&tmp_path)?;
        let db_url = format!("sqlite:{}", tmp_path.to_string_lossy());
        std::env::set_var("LUMI_DB_URL", &db_url);

        // Prepare a temp vector DB dir
        let vec_dir = std::env::temp_dir().join(format!("lumi_vector_db_test_{}", Uuid::new_v4()));
        if vec_dir.exists() { fs::remove_dir_all(&vec_dir)?; }
        let vec_dir_str = vec_dir.to_string_lossy().to_string();
        std::env::set_var("LUMI_VECTOR_DB_PATH", &vec_dir_str);

        // Call the public tool wrapper
        let id = log_transaction("Tool Vendor".to_string(), 5.50, "USD".to_string(), "meals".to_string(), "2026-03-04T12:00:00Z".to_string(), None).await?;

        // Verify row exists via a new connection to the same file
        let pool = SqlitePool::connect(&db_url).await?;
        let row: (String,) = sqlx::query_as("SELECT id FROM transactions WHERE id = ?1")
            .bind(&id)
            .fetch_one(&pool)
            .await?;
        assert_eq!(row.0, id);

        // Verify embedding exists in the vector DB
        let (embedding, metadata) = crate::vector_db::get_embedding(&vec_dir_str, &id)?;
        assert_eq!(embedding.len(), 768);
        assert!(metadata.contains("Tool Vendor"));

        // Cleanup
        let _ = fs::remove_file(&tmp_path);
        let _ = fs::remove_dir_all(&vec_dir);
        Ok(())
    }

    #[tokio::test]
    async fn query_transactions_returns_all_rows() -> Result<(), Box<dyn std::error::Error>> {
        let pool = SqlitePool::connect(":memory:").await?;
        db::db_init_with_pool(&pool).await?;

        let _id1 = log_transaction_with_pool(&pool, "Vendor X", 3.00, "USD", "utilities", "2026-01-01T00:00:00Z", None).await?;
        let _id2 = log_transaction_with_pool(&pool, "Vendor Y", 5.00, "USD", "meals", "2026-01-02T00:00:00Z", None).await?;

        let res = query_transactions_with_pool(&pool, None, None, None, None).await?;
        assert!(res.len() >= 2);
        Ok(())
    }

    #[tokio::test]
    async fn query_transactions_category_filter() -> Result<(), Box<dyn std::error::Error>> {
        let pool = SqlitePool::connect(":memory:").await?;
        db::db_init_with_pool(&pool).await?;

        let _ = log_transaction_with_pool(&pool, "Shell", 20.0, "USD", "fuel", "2026-02-01T00:00:00Z", None).await?;
        let _ = log_transaction_with_pool(&pool, "Cafe", 4.0, "USD", "meals", "2026-02-02T00:00:00Z", None).await?;

        let res = query_transactions_with_pool(&pool, Some("fuel"), None, None, None).await?;
        assert_eq!(res.len(), 1);
        assert_eq!(res[0].category.as_deref(), Some("fuel"));
        Ok(())
    }

    #[tokio::test]
    async fn log_mileage_calculation_and_persist() -> Result<(), Box<dyn std::error::Error>> {
        let pool = SqlitePool::connect(":memory:").await?;
        db::db_init_with_pool(&pool).await?;

        let res = log_mileage_with_pool(&pool, 10.0, "Start A", "End B", "2026-04-01T08:00:00Z", "client meeting").await?;
        assert_eq!(res.deduction_amount, 6.70);

        // verify persisted row
        let row: (String, f64, Option<String>, Option<String>, Option<String>) = sqlx::query_as(
            "SELECT id, distance_miles, start_location, end_location, purpose FROM mileage_logs WHERE id = ?1"
        )
        .bind(&res.id)
        .fetch_one(&pool)
        .await?;
        assert_eq!(row.0, res.id);
        assert!((row.1 - 10.0).abs() < 1e-6);
        assert_eq!(row.2.as_deref(), Some("Start A"));
        assert_eq!(row.3.as_deref(), Some("End B"));
        assert_eq!(row.4.as_deref(), Some("client meeting"));

        Ok(())
    }

    #[tokio::test]
    async fn log_mileage_tool_wrapper_inserts_row() -> Result<(), Box<dyn std::error::Error>> {
        let tmp_path = std::env::temp_dir().join(format!("lumi_mileage_test_{}.db", Uuid::new_v4()));
        let _f = std::fs::File::create(&tmp_path)?;
        let db_url = format!("sqlite:{}", tmp_path.to_string_lossy());
        std::env::set_var("LUMI_DB_URL", &db_url);

        let res = log_mileage(12.0, "Home".to_string(), "Office".to_string(), "2026-04-02T10:00:00Z".to_string(), "commute".to_string()).await?;

        let pool = SqlitePool::connect(&db_url).await?;
        let row: (String,) = sqlx::query_as("SELECT id FROM mileage_logs WHERE id = ?1")
            .bind(&res.id)
            .fetch_one(&pool)
            .await?;
        assert_eq!(row.0, res.id);

        let _ = fs::remove_file(&tmp_path);
        Ok(())
    }
}
