#![allow(dead_code)]
use sqlx::SqlitePool;
use sqlx::Row;
use serde_json::json;
use sha2::{Sha256, Digest};
use hex;
use chrono::{DateTime, Utc, Datelike, TimeZone};
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


#[rig_macros::tool(description = "Search transaction history semantically using natural language")]
pub async fn semantic_search(
    query: String,
    top_k: Option<u32>,
) -> anyhow::Result<Vec<TransactionSummary>> {
    let topk = top_k.unwrap_or(5);
    let db_url = std::env::var("LUMI_DB_URL").unwrap_or_else(|_| "sqlite:lumi.db".to_string());
    let pool = SqlitePool::connect(&db_url)
        .await
        .map_err(|e| anyhow!(format!("failed to connect to db: {}", e)))?;

    // Ensure schema exists
    if let Err(e) = crate::db::db_init_with_pool(&pool).await {
        return Err(anyhow!(format!("db_init failed: {}", e)));
    }

    let vector_db_path = std::env::var("LUMI_VECTOR_DB_PATH").unwrap_or_else(|_| "./vector_db".to_string());

    // embed query
    let qvec = match crate::embeddings::embed_text(&query) {
        Ok(v) => v,
        Err(e) => return Err(anyhow!(format!("embed_text failed: {}", e))),
    };

    let results = match crate::vector_db::vector_search(&vector_db_path, &qvec, topk) {
        Ok(r) => r,
        Err(e) => return Err(anyhow!(format!("vector_search failed: {}", e))),
    };

    let mut out: Vec<TransactionSummary> = Vec::new();
    for (id, _score, _meta) in results {
        let row_opt = sqlx::query("SELECT id, vendor, amount, currency, category, timestamp, is_tagged FROM transactions WHERE id = ?1")
            .bind(&id)
            .fetch_optional(&pool)
            .await
            .map_err(|e| anyhow!(format!("db query failed: {}", e)))?;
        if let Some(row) = row_opt {
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
    }

    Ok(out)
}


#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct FinancialSummary {
    pub period: String,
    pub total_expenses: f64,
    pub top_categories: Vec<(String, f64)>,
    pub total_miles: f64,
    pub estimated_deduction: f64,
    pub working_hours: Option<f64>,
}

#[doc(hidden)]
pub async fn get_summary_with_pool(pool: &SqlitePool, period: &str) -> anyhow::Result<FinancialSummary> {
    let now = Utc::now();
    let (start_ts, end_ts) = match period {
        "this_month" => {
            let start = Utc.ymd(now.year(), now.month(), 1).and_hms(0,0,0);
            (start.timestamp(), now.timestamp())
        }
        "last_month" => {
            let (y, m) = if now.month() == 1 { (now.year() - 1, 12) } else { (now.year(), now.month() - 1) };
            let start = Utc.ymd(y, m, 1).and_hms(0,0,0);
            let end = if m == 12 {
                Utc.ymd(y + 1, 1, 1).and_hms(0,0,0).checked_sub_signed(chrono::Duration::seconds(1)).unwrap()
            } else {
                Utc.ymd(y, m + 1, 1).and_hms(0,0,0).checked_sub_signed(chrono::Duration::seconds(1)).unwrap()
            };
            (start.timestamp(), end.timestamp())
        }
        "ytd" => {
            let start = Utc.ymd(now.year(), 1, 1).and_hms(0,0,0);
            (start.timestamp(), now.timestamp())
        }
        _ => return Err(anyhow!(format!("unknown period: {}", period))),
    };

    // total expenses
    let total_cents: Option<i64> = sqlx::query_scalar("SELECT SUM(amount) FROM transactions WHERE timestamp >= ?1 AND timestamp <= ?2")
        .bind(start_ts)
        .bind(end_ts)
        .fetch_one(pool)
        .await
        .map_err(|e| anyhow!(format!("total query failed: {}", e)))?;
    let total_expenses = total_cents.unwrap_or(0) as f64 / 100.0;

    // top categories
    let rows = sqlx::query("SELECT category, SUM(amount) as total FROM transactions WHERE timestamp >= ?1 AND timestamp <= ?2 GROUP BY category ORDER BY total DESC LIMIT 5")
        .bind(start_ts)
        .bind(end_ts)
        .fetch_all(pool)
        .await
        .map_err(|e| anyhow!(format!("top categories query failed: {}", e)))?;
    let mut top_categories: Vec<(String, f64)> = Vec::new();
    for r in rows {
        let cat: Option<String> = r.try_get("category")?;
        let cents: i64 = r.try_get("total")?;
        if let Some(c) = cat {
            top_categories.push((c, cents as f64 / 100.0));
        }
    }

    // mileage sums
    let total_miles_opt: Option<f64> = sqlx::query_scalar("SELECT SUM(distance_miles) FROM mileage_logs WHERE timestamp >= ?1 AND timestamp <= ?2")
        .bind(start_ts)
        .bind(end_ts)
        .fetch_one(pool)
        .await
        .map_err(|e| anyhow!(format!("miles query failed: {}", e)))?;
    let total_miles = total_miles_opt.unwrap_or(0.0);

    let total_deduction_opt: Option<f64> = sqlx::query_scalar("SELECT SUM(deduction_amount) FROM mileage_logs WHERE timestamp >= ?1 AND timestamp <= ?2")
        .bind(start_ts)
        .bind(end_ts)
        .fetch_one(pool)
        .await
        .map_err(|e| anyhow!(format!("deduction query failed: {}", e)))?;
    let estimated_deduction = total_deduction_opt.unwrap_or(0.0);

    // working hours not yet implemented
    let working_hours = None;

    Ok(FinancialSummary {
        period: period.to_string(),
        total_expenses,
        top_categories,
        total_miles,
        estimated_deduction,
        working_hours,
    })
}

#[rig_macros::tool(description = "Return a financial summary for a given period")]
pub async fn get_summary(period: String) -> anyhow::Result<FinancialSummary> {
    let db_url = std::env::var("LUMI_DB_URL").unwrap_or_else(|_| "sqlite:lumi.db".to_string());
    let pool = SqlitePool::connect(&db_url)
        .await
        .map_err(|e| anyhow!(format!("failed to connect to db: {}", e)))?;

    // Ensure schema exists
    if let Err(e) = crate::db::db_init_with_pool(&pool).await {
        return Err(anyhow!(format!("db_init failed: {}", e)));
    }

    get_summary_with_pool(&pool, &period).await
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::db;
    use sqlx::SqlitePool;
    use uuid::Uuid;
    use serial_test::serial;
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
    #[serial]
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
        // Ensure vector DB initialized so the upsert in log_transaction succeeds
        crate::vector_db::vector_db_init(&vec_dir_str)?;

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
    #[serial]
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

    #[tokio::test]
    #[serial]
    async fn semantic_search_returns_seeded_transaction() -> Result<(), Box<dyn std::error::Error>> {
        use crate::embeddings;
        use crate::vector_db;
        use sqlx::SqlitePool;
        use std::fs;
        use uuid::Uuid;

        // save/restore env vars to avoid test interference
        let prev_db = std::env::var("LUMI_DB_URL").ok();
        let prev_vec = std::env::var("LUMI_VECTOR_DB_PATH").ok();

        // prepare temp sqlite db
        let tmp_db = std::env::temp_dir().join(format!("lumi_sem_search_{}.db", Uuid::new_v4()));
        let _f = std::fs::File::create(&tmp_db)?;
        let db_url = format!("sqlite:{}", tmp_db.to_string_lossy());
        std::env::set_var("LUMI_DB_URL", &db_url);

        // prepare temp vector db
        let vec_dir = std::env::temp_dir().join(format!("lumi_vector_sem_search_{}", Uuid::new_v4()));
        if vec_dir.exists() { fs::remove_dir_all(&vec_dir)?; }
        let vec_dir_str = vec_dir.to_string_lossy().to_string();
        std::env::set_var("LUMI_VECTOR_DB_PATH", &vec_dir_str);
        crate::vector_db::vector_db_init(&vec_dir_str)?;

        // init sqlite schema
        let pool = SqlitePool::connect(&db_url).await?;
        crate::db::db_init_with_pool(&pool).await?;

        // create a deterministic query and matching embedding
        let query = "unique-query-for-test-123";
        let emb = embeddings::embed_text(query)?;

        // insert a transaction row with id matching embedding id
        let id = Uuid::new_v4().to_string();
        let amount_cents: i64 = 425;
        let timestamp: i64 = 1_700_000_000;
        let insert_sql = "INSERT INTO transactions (id, amount, currency, vendor, category, timestamp, receipt_path, is_tagged, sha256_hash) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)";
        sqlx::query(insert_sql)
            .bind(&id)
            .bind(amount_cents)
            .bind("USD")
            .bind("TestVendor")
            .bind("testing")
            .bind(timestamp)
            .bind(Option::<String>::None)
            .bind(0i32)
            .bind("sha-placeholder")
            .execute(&pool)
            .await?;

        // upsert embedding for that id using the same embedding as query
        vector_db::upsert_embedding(&vec_dir_str, &id, &emb, &format!("{{\"vendor\":\"TestVendor\"}}"))?;

        // call semantic_search
        let res = semantic_search(query.to_string(), None).await?;
        assert!(!res.is_empty());
        assert_eq!(res[0].id, id);

        // cleanup
        let _ = fs::remove_file(&tmp_db);
        let _ = fs::remove_dir_all(&vec_dir);

        // restore env
        if let Some(v) = prev_db { std::env::set_var("LUMI_DB_URL", v); } else { std::env::remove_var("LUMI_DB_URL"); }
        if let Some(v) = prev_vec { std::env::set_var("LUMI_VECTOR_DB_PATH", v); } else { std::env::remove_var("LUMI_VECTOR_DB_PATH"); }

        Ok(())
    }

    #[tokio::test]
    #[serial]
    async fn semantic_search_respects_default_top_k() -> Result<(), Box<dyn std::error::Error>> {
        use crate::embeddings;
        use crate::vector_db;
        use sqlx::SqlitePool;
        use std::fs;
        use uuid::Uuid;

        // save/restore env vars to avoid test interference
        let prev_db = std::env::var("LUMI_DB_URL").ok();
        let prev_vec = std::env::var("LUMI_VECTOR_DB_PATH").ok();

        // prepare temp sqlite db
        let tmp_db = std::env::temp_dir().join(format!("lumi_sem_search_topk_{}.db", Uuid::new_v4()));
        let _f = std::fs::File::create(&tmp_db)?;
        let db_url = format!("sqlite:{}", tmp_db.to_string_lossy());
        std::env::set_var("LUMI_DB_URL", &db_url);

        // prepare temp vector db
        let vec_dir = std::env::temp_dir().join(format!("lumi_vector_sem_search_topk_{}", Uuid::new_v4()));
        if vec_dir.exists() { fs::remove_dir_all(&vec_dir)?; }
        let vec_dir_str = vec_dir.to_string_lossy().to_string();
        std::env::set_var("LUMI_VECTOR_DB_PATH", &vec_dir_str);
        crate::vector_db::vector_db_init(&vec_dir_str)?;

        // init sqlite schema
        let pool = SqlitePool::connect(&db_url).await?;
        crate::db::db_init_with_pool(&pool).await?;

        // build a shared embedding for all inserted transactions
        let query = "common-search-term-topk";
        let emb = embeddings::embed_text(query)?;

        // insert 10 transactions with embeddings identical to query emb
        for i in 0..10 {
            let id = format!("topk-{}", i);
            let amount_cents: i64 = 100 + i as i64;
            let timestamp: i64 = 1_700_000_000 + i as i64;
            sqlx::query("INSERT INTO transactions (id, amount, currency, vendor, category, timestamp, receipt_path, is_tagged, sha256_hash) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)")
                .bind(&id)
                .bind(amount_cents)
                .bind("USD")
                .bind(format!("Vendor{}", i))
                .bind("misc")
                .bind(timestamp)
                .bind(Option::<String>::None)
                .bind(0i32)
                .bind(format!("sha-{}", i))
                .execute(&pool)
                .await?;
            vector_db::upsert_embedding(&vec_dir_str, &id, &emb, &format!("{{\"vendor\":\"Vendor{}\"}}", i))?;
        }

        // semantic_search with None top_k should default to 5
        let res = semantic_search(query.to_string(), None).await?;
        assert_eq!(res.len(), 5);

        // cleanup
        let _ = fs::remove_file(&tmp_db);
        let _ = fs::remove_dir_all(&vec_dir);

        // restore env
        if let Some(v) = prev_db { std::env::set_var("LUMI_DB_URL", v); } else { std::env::remove_var("LUMI_DB_URL"); }
        if let Some(v) = prev_vec { std::env::set_var("LUMI_VECTOR_DB_PATH", v); } else { std::env::remove_var("LUMI_VECTOR_DB_PATH"); }

        Ok(())
    }

    #[tokio::test]
    #[serial]
    async fn get_summary_this_month_returns_correct_totals() -> Result<(), Box<dyn std::error::Error>> {
        use uuid::Uuid;
        // prepare temp sqlite db file so multiple connections share data
        let tmp_db = std::env::temp_dir().join(format!("lumi_summary_test_{}.db", Uuid::new_v4()));
        let _f = std::fs::File::create(&tmp_db)?;
        let db_url = format!("sqlite:{}", tmp_db.to_string_lossy());
        std::env::set_var("LUMI_DB_URL", &db_url);

        // init sqlite schema
        let pool = SqlitePool::connect(&db_url).await?;
        crate::db::db_init_with_pool(&pool).await?;

        // insert two transactions in this month
        let now = Utc::now();
        let date_str = now.to_rfc3339();
        let _ = log_transaction_with_pool(&pool, "Vendor A", 10.0, "USD", "utilities", &date_str, None).await?;
        let _ = log_transaction_with_pool(&pool, "Vendor B", 5.50, "USD", "meals", &date_str, None).await?;

        // insert mileage log
        let _ = log_mileage_with_pool(&pool, 10.0, "Start", "End", &date_str, "test").await?;

        // call get_summary via pool-backed helper
        let summary = get_summary_with_pool(&pool, "this_month").await?;
        // Verify totals
        assert!((summary.total_expenses - 15.50).abs() < 1e-6, "unexpected total_expenses: {}", summary.total_expenses);
        assert!((summary.total_miles - 10.0).abs() < 1e-6, "unexpected total_miles: {}", summary.total_miles);
        assert!((summary.estimated_deduction - 6.70).abs() < 1e-6, "unexpected estimated_deduction: {}", summary.estimated_deduction);
        // top categories should include utilities and meals
        let cats: Vec<String> = summary.top_categories.iter().map(|(c, _)| c.clone()).collect();
        assert!(cats.contains(&"utilities".to_string()));
        assert!(cats.contains(&"meals".to_string()));

        // cleanup
        let _ = fs::remove_file(&tmp_db);
        // unset env
        std::env::remove_var("LUMI_DB_URL");

        Ok(())
    }

    #[tokio::test]
    async fn get_summary_unknown_period_returns_error() -> Result<(), Box<dyn std::error::Error>> {
        // prepare temp sqlite db file
        let tmp_db = std::env::temp_dir().join(format!("lumi_summary_test_{}.db", Uuid::new_v4()));
        let _f = std::fs::File::create(&tmp_db)?;
        let db_url = format!("sqlite:{}", tmp_db.to_string_lossy());
        std::env::set_var("LUMI_DB_URL", &db_url);

        let pool = SqlitePool::connect(&db_url).await?;
        crate::db::db_init_with_pool(&pool).await?;

        let res = get_summary_with_pool(&pool, "not-a-period").await;
        assert!(res.is_err());

        let _ = fs::remove_file(&tmp_db);
        std::env::remove_var("LUMI_DB_URL");
        Ok(())
    }
}
