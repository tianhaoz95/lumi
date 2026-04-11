use sqlx::SqlitePool;

/// Initialize the SQLite schema for Lumi core.
///
/// This creates the following tables if they do not already exist:
/// - transactions
/// - mileage_logs
/// - users
///
/// Two helper functions are provided:
/// - db_init_with_pool(pool: &SqlitePool) -> Result<(), sqlx::Error>
/// - db_init(db_url: &str) -> Result<(), sqlx::Error>

pub async fn db_init_with_pool(pool: &SqlitePool) -> Result<(), sqlx::Error> {
    // Use SQL DDL for portability and simplicity in tests.
    // transactions table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS transactions (
            id TEXT PRIMARY KEY,
            amount INTEGER NOT NULL,
            currency TEXT NOT NULL,
            vendor TEXT,
            category TEXT,
            timestamp INTEGER NOT NULL,
            receipt_path TEXT,
            is_tagged INTEGER NOT NULL DEFAULT 0,
            sha256_hash TEXT
        );
        "#,
    )
    .execute(pool)
    .await?;

    // mileage_logs table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS mileage_logs (
            id TEXT PRIMARY KEY,
            distance_miles REAL NOT NULL,
            start_lat REAL,
            start_lng REAL,
            end_lat REAL,
            end_lng REAL,
            timestamp INTEGER NOT NULL,
            deduction_amount REAL
        );
        "#,
    )
    .execute(pool)
    .await?;

    // users table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            appwrite_user_id TEXT UNIQUE,
            display_name TEXT
        );
        "#,
    )
    .execute(pool)
    .await?;

    Ok(())
}

pub async fn db_init(db_url: &str) -> Result<(), sqlx::Error> {
    // Connect to the SQLite database at db_url and run migrations
    let pool = SqlitePool::connect(db_url).await?;
    db_init_with_pool(&pool).await
}
