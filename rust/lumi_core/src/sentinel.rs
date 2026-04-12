use chrono::{Utc, Duration, TimeZone, Datelike};
use sqlx::SqlitePool;
use sqlx::Row;
use serde::{Serialize, Deserialize};
use anyhow::Result;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct SentinelReport {
    pub untagged_count: u32,
    pub missing_days: Vec<String>,   // ISO 8601 dates
    pub incomplete_mileage: Vec<u64>, // mileage_log IDs (numeric ids)
}

/// Run a sentinel scan against the provided SqlitePool and return a report.
pub async fn run_sentinel_scan_with_pool(pool: &SqlitePool) -> Result<SentinelReport, sqlx::Error> {
    // 1) Count untagged transactions in past 7 days
    let seven_days_ago = (Utc::now() - Duration::days(7)).timestamp();

    let row: (i64,) = sqlx::query_as("SELECT COUNT(*) as c FROM transactions WHERE is_tagged = 0 AND timestamp >= ?1")
        .bind(seven_days_ago)
        .fetch_one(pool)
        .await?;
    let untagged_count = row.0 as u32;

    // 2) Find missing days in the past 14 days with zero transaction entries
    let mut missing_days: Vec<String> = Vec::new();

    for i in 0..14 {
        let day = Utc::now().date_naive() - chrono::Duration::days(i);
        // start of day UTC
        let day_start = DateTimeFromNaive(day, 0, 0, 0);
        let day_end = DateTimeFromNaive(day + chrono::Duration::days(1), 0, 0, 0);

        let cnt_row: (i64,) = sqlx::query_as("SELECT COUNT(*) as c FROM transactions WHERE timestamp >= ?1 AND timestamp < ?2")
            .bind(day_start)
            .bind(day_end)
            .fetch_one(pool)
            .await?;
        if cnt_row.0 == 0 {
            missing_days.push(day.format("%Y-%m-%d").to_string());
        }
    }

    // 3) Mileage logs without purpose
    let rows = sqlx::query("SELECT id FROM mileage_logs WHERE purpose IS NULL OR TRIM(purpose) = ''")
        .fetch_all(pool)
        .await?;
    let mut incomplete_mileage: Vec<u64> = Vec::new();
    for r in rows {
        // mileage_logs.id is stored as integer in the DB; read as i64 and cast to u64
        let id_i64: i64 = r.try_get("id")?;
        incomplete_mileage.push(id_i64 as u64);
    }

    Ok(SentinelReport { untagged_count, missing_days, incomplete_mileage })
}

fn DateTimeFromNaive(d: chrono::NaiveDate, h: u32, m: u32, s: u32) -> i64 {
    // create a DateTime<Utc> from a NaiveDate at provided time and return unix timestamp
    let ndt = d.and_hms(h, m, s);
    let dt = chrono::DateTime::<Utc>::from_utc(ndt, Utc);
    dt.timestamp()
}

#[rig_macros::tool(description = "Run sentinel scan and return a SentinelReport")]
pub async fn run_sentinel_scan() -> anyhow::Result<SentinelReport> {
    let db_url = std::env::var("LUMI_DB_URL").unwrap_or_else(|_| "sqlite:lumi.db".to_string());
    let pool = SqlitePool::connect(&db_url).await.map_err(|e| anyhow::anyhow!(format!("failed to connect to db: {}", e)))?;

    // Ensure schema exists
    crate::db::db_init_with_pool(&pool).await.map_err(|e| anyhow::anyhow!(format!("db_init failed: {}", e)))?;

    let report = run_sentinel_scan_with_pool(&pool).await.map_err(|e| anyhow::anyhow!(format!("scan failed: {}", e)))?;

    // Persist a lightweight record of the scan to sentinel_logs for auditing and battery monitoring
    match serde_json::to_string(&report) {
        Ok(report_json) => {
            // Insert a row summarizing counts and the full JSON blob
            let _ = sqlx::query("INSERT INTO sentinel_logs (ts, report_json, untagged_count, missing_days_count, incomplete_mileage_count) VALUES (?1, ?2, ?3, ?4, ?5)")
                .bind(Utc::now().timestamp())
                .bind(report_json)
                .bind(report.untagged_count as i64)
                .bind(report.missing_days.len() as i64)
                .bind(report.incomplete_mileage.len() as i64)
                .execute(&pool)
                .await;
        }
        Err(e) => {
            eprintln!("failed to serialize sentinel report for logging: {}", e);
        }
    }

    Ok(report)
}
