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

    // Run the scan but enforce a 30-second maximum using tokio::time::timeout
    match run_with_timeout(run_sentinel_scan_with_pool(&pool), std::time::Duration::from_secs(30)).await {
        Ok(report) => {
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
        Err(e) => {
            // Bubble up timeout or scan errors as anyhow errors
            Err(e)
        }
    }
}

// Helper that wraps a future returning Result<T, sqlx::Error> and enforces a timeout in seconds.
async fn run_with_timeout<Fut, T>(fut: Fut, dur: std::time::Duration) -> Result<T, anyhow::Error>
where
    Fut: std::future::Future<Output = Result<T, sqlx::Error>>,
{
    match tokio::time::timeout(dur, fut).await {
        Ok(Ok(v)) => Ok(v),
        Ok(Err(e)) => Err(anyhow::anyhow!(format!("scan failed: {}", e))),
        Err(_) => {
            eprintln!("run_sentinel_scan timed out after {:?}", dur);
            Err(anyhow::anyhow!("scan timed out"))
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::time::Duration;

    #[tokio::test]
    async fn run_with_timeout_times_out() {
        // Use small durations so the unit test runs quickly without relying on tokio test utilities
        let fut = run_with_timeout(async {
            tokio::time::sleep(Duration::from_millis(200)).await;
            Ok::<SentinelReport, sqlx::Error>(SentinelReport { untagged_count: 0, missing_days: vec![], incomplete_mileage: vec![] })
        }, Duration::from_millis(100));

        let res = fut.await;
        assert!(res.is_err());
        assert_eq!(res.unwrap_err().to_string(), "scan timed out");
    }
}

#[rig_macros::tool(description = "Update last sentinel log with battery levels")]
pub async fn update_last_sentinel_battery(battery_before: Option<i64>, battery_after: Option<i64>) -> anyhow::Result<()> {
    let db_url = std::env::var("LUMI_DB_URL").unwrap_or_else(|_| "sqlite:lumi.db".to_string());
    let pool = SqlitePool::connect(&db_url).await.map_err(|e| anyhow::anyhow!(format!("failed to connect to db: {}", e)))?;

    // compute delta if both provided
    let battery_delta: Option<i64> = match (battery_before, battery_after) {
        (Some(b1), Some(b2)) => Some(b2 - b1),
        _ => None,
    };

    // Update the most recent sentinel_logs row (if any) with battery info
    let _ = sqlx::query(
        "UPDATE sentinel_logs SET battery_before = ?1, battery_after = ?2, battery_delta = ?3 WHERE id = (SELECT id FROM sentinel_logs ORDER BY id DESC LIMIT 1)"
    )
    .bind(battery_before)
    .bind(battery_after)
    .bind(battery_delta)
    .execute(&pool)
    .await;

    Ok(())
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct SentinelHealth {
    pub last_scan_ts: Option<i64>,
    pub avg_battery_delta: Option<f64>,
    pub scans_last_24h: i64,
}

#[rig_macros::tool(description = "Get sentinel health summary")]
pub async fn get_sentinel_health() -> anyhow::Result<SentinelHealth> {
    let db_url = std::env::var("LUMI_DB_URL").unwrap_or_else(|_| "sqlite:lumi.db".to_string());
    let pool = SqlitePool::connect(&db_url).await.map_err(|e| anyhow::anyhow!(format!("failed to connect to db: {}", e)))?;

    // last scan timestamp (max ts)
    let last_row: Option<(Option<i64>,)> = sqlx::query_as("SELECT MAX(ts) FROM sentinel_logs")
        .fetch_optional(&pool)
        .await?;
    let last_scan_ts = match last_row {
        Some((maybe_ts,)) => maybe_ts,
        None => None,
    };

    // average battery delta (nullable)
    let avg_row: Option<(Option<f64>,)> = sqlx::query_as("SELECT AVG(battery_delta) as avg_delta FROM sentinel_logs WHERE battery_delta IS NOT NULL")
        .fetch_optional(&pool)
        .await?;
    let avg_battery_delta = match avg_row {
        Some((maybe_avg,)) => maybe_avg,
        None => None,
    };

    // scans in last 24 hours
    let cutoff = Utc::now().timestamp() - (24 * 3600);
    let cnt_row: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM sentinel_logs WHERE ts >= ?1")
        .bind(cutoff)
        .fetch_one(&pool)
        .await?;
    let scans_last_24h = cnt_row.0 as i64;

    Ok(SentinelHealth { last_scan_ts, avg_battery_delta, scans_last_24h })
}
