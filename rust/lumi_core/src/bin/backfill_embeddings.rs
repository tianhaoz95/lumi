use anyhow::Result;
use sqlx::SqlitePool;
use std::env;

#[tokio::main]
async fn main() -> Result<()> {
    // DB and vector DB paths from env or defaults
    let db_url = env::var("LUMI_DB_URL").unwrap_or_else(|_| "sqlite:lumi.db".to_string());
    let vector_db_path = env::var("LUMI_VECTOR_DB_PATH").unwrap_or_else(|_| "./vector_db".to_string());

    // Connect to sqlite
    let pool = SqlitePool::connect(&db_url).await.map_err(|e| anyhow::anyhow!(format!("failed to connect to db: {}", e)))?;

    // Ensure schema exists
    lumi_core::db_init_with_pool(&pool).await.map_err(|e| anyhow::anyhow!(format!("db_init failed: {}", e)))?;

    // Ensure vector DB initialized (best-effort)
    if let Err(e) = lumi_core::vector_db_init(&vector_db_path) {
        eprintln!("vector_db_init failed: {}", e);
    }

    // Fetch all transactions (no filters)
    let txs = lumi_core::query_transactions_with_pool(&pool, None, None, None, None).await.map_err(|e| anyhow::anyhow!(format!("query failed: {}", e)))?;

    let mut inserted = 0usize;
    let mut failed = 0usize;

    for tx in txs.iter() {
        // Build embedding
        match lumi_core::embed_transaction_from_summary(tx) {
            Ok(emb) => {
                // Build metadata JSON
                let meta = serde_json::json!({
                    "vendor": tx.vendor.clone(),
                    "amount": tx.amount,
                    "currency": tx.currency.clone(),
                    "category": tx.category.clone(),
                    "timestamp": tx.timestamp,
                });
                let meta_str = meta.to_string();
                match lumi_core::upsert_embedding(&vector_db_path, &tx.id, &emb, &meta_str) {
                    Ok(_) => inserted += 1,
                    Err(e) => {
                        eprintln!("upsert_embedding failed for {}: {}", tx.id, e);
                        failed += 1;
                    }
                }
            }
            Err(e) => {
                eprintln!("embed_transaction failed for {}: {}", tx.id, e);
                failed += 1;
            }
        }
    }

    println!("Embedded {} transactions ({} failures)", inserted, failed);
    Ok(())
}
