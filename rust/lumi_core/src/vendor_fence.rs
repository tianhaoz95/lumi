use chrono::Utc;
use sqlx::SqlitePool;
use sqlx::Row;
use serde::{Serialize, Deserialize};
use anyhow::Result;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct VendorFence {
    pub id: String,
    pub vendor_name: String,
    pub lat: f64,
    pub lng: f64,
    pub radius_meters: f64,
    pub visit_count: i64,
    pub last_visited: Option<String>,
}

pub async fn add_vendor_fence_with_pool(pool: &SqlitePool, name: &str, lat: f64, lng: f64) -> Result<String, sqlx::Error> {
    let id = uuid::Uuid::new_v4().to_string();
    let radius = 150.0f64;
    sqlx::query("INSERT INTO vendor_fences (id, vendor_name, lat, lng, radius_meters, visit_count, last_visited) VALUES (?1, ?2, ?3, ?4, ?5, 0, NULL)")
        .bind(&id)
        .bind(name)
        .bind(lat)
        .bind(lng)
        .bind(radius)
        .execute(pool)
        .await?;
    Ok(id)
}

pub async fn get_all_fences_with_pool(pool: &SqlitePool) -> Result<Vec<VendorFence>, sqlx::Error> {
    let rows = sqlx::query("SELECT id, vendor_name, lat, lng, radius_meters, visit_count, last_visited FROM vendor_fences")
        .fetch_all(pool)
        .await?;
    let mut fences: Vec<VendorFence> = Vec::new();
    for r in rows {
        let id: String = r.try_get("id")?;
        let vendor_name: String = r.try_get("vendor_name")?;
        let lat: f64 = r.try_get("lat")?;
        let lng: f64 = r.try_get("lng")?;
        let radius_meters: f64 = r.try_get("radius_meters")?;
        let visit_count: i64 = r.try_get("visit_count")?;
        let last_visited: Option<String> = r.try_get("last_visited").ok();
        fences.push(VendorFence { id, vendor_name, lat, lng, radius_meters, visit_count, last_visited });
    }
    Ok(fences)
}

pub async fn increment_visit_with_pool(pool: &SqlitePool, fence_id: &str) -> Result<(), sqlx::Error> {
    let now = Utc::now().to_rfc3339();
    sqlx::query("UPDATE vendor_fences SET visit_count = visit_count + 1, last_visited = ?1 WHERE id = ?2")
        .bind(now)
        .bind(fence_id)
        .execute(pool)
        .await?;
    Ok(())
}

// FRB / rig tool wrappers
#[rig_macros::tool(description = "Add vendor fence and return id")]
pub async fn add_vendor_fence(name: String, lat: f64, lng: f64) -> anyhow::Result<String> {
    let db_url = std::env::var("LUMI_DB_URL").unwrap_or_else(|_| "sqlite:lumi.db".to_string());
    let pool = SqlitePool::connect(&db_url).await.map_err(|e| anyhow::anyhow!(format!("failed to connect to db: {}", e)))?;
    crate::db::db_init_with_pool(&pool).await.map_err(|e| anyhow::anyhow!(format!("db_init failed: {}", e)))?;
    let id = add_vendor_fence_with_pool(&pool, &name, lat, lng).await.map_err(|e| anyhow::anyhow!(format!("insert failed: {}", e)))?;
    Ok(id)
}

#[rig_macros::tool(description = "Get all vendor fences")]
pub async fn get_all_fences() -> anyhow::Result<Vec<VendorFence>> {
    let db_url = std::env::var("LUMI_DB_URL").unwrap_or_else(|_| "sqlite:lumi.db".to_string());
    let pool = SqlitePool::connect(&db_url).await.map_err(|e| anyhow::anyhow!(format!("failed to connect to db: {}", e)))?;
    crate::db::db_init_with_pool(&pool).await.map_err(|e| anyhow::anyhow!(format!("db_init failed: {}", e)))?;
    let fences = get_all_fences_with_pool(&pool).await.map_err(|e| anyhow::anyhow!(format!("query failed: {}", e)))?;
    Ok(fences)
}

#[rig_macros::tool(description = "Increment vendor fence visit_count and set last_visited")] 
pub async fn increment_visit(fence_id: String) -> anyhow::Result<()> {
    let db_url = std::env::var("LUMI_DB_URL").unwrap_or_else(|_| "sqlite:lumi.db".to_string());
    let pool = SqlitePool::connect(&db_url).await.map_err(|e| anyhow::anyhow!(format!("failed to connect to db: {}", e)))?;
    crate::db::db_init_with_pool(&pool).await.map_err(|e| anyhow::anyhow!(format!("db_init failed: {}", e)))?;
    increment_visit_with_pool(&pool, &fence_id).await.map_err(|e| anyhow::anyhow!(format!("increment failed: {}", e)))?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::db::db_init_with_pool;
    use sqlx::SqlitePool;

    #[tokio::test]
    async fn vendor_fence_crud() -> Result<(), sqlx::Error> {
        let pool = SqlitePool::connect(":memory:").await?;
        db_init_with_pool(&pool).await?;

        let id = add_vendor_fence_with_pool(&pool, "Test Vendor", 1.23, 4.56).await?;
        assert!(!id.is_empty());

        let fences = get_all_fences_with_pool(&pool).await?;
        assert!(fences.len() >= 1);
        let f = fences.into_iter().find(|x| x.id == id).expect("inserted fence not found");
        assert_eq!(f.vendor_name, "Test Vendor");
        assert_eq!(f.visit_count, 0);

        increment_visit_with_pool(&pool, &id).await?;
        let fences2 = get_all_fences_with_pool(&pool).await?;
        let f2 = fences2.into_iter().find(|x| x.id == id).expect("fence missing after increment");
        assert!(f2.visit_count >= 1);
        Ok(())
    }
}
