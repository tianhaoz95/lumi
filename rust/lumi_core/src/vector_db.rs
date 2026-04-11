use std::fs;
use std::path::{Path, PathBuf};
use std::io::{Read, Write};
use serde::{Serialize, Deserialize};

/// Initialize a simple on-disk vector DB placeholder for Lumi.
///
/// For Phase 1 this creates the directory and a sentinel file and provides a
/// minimal "transaction_embeddings" table backed by JSON files so unit tests
/// can run without pulling in LanceDB native dependencies.
pub fn vector_db_init(db_path: &str) -> Result<(), std::io::Error> {
    let path = Path::new(db_path);
    if !path.exists() {
        fs::create_dir_all(path)?;
    }
    // Create a sentinel file indicating initialization completed.
    let marker = path.join("lance_db_init");
    fs::write(marker, b"lumi vector db initialized")?;

    // Ensure transaction_embeddings directory exists
    let emb_dir = path.join("transaction_embeddings");
    if !emb_dir.exists() {
        fs::create_dir_all(emb_dir)?;
    }

    Ok(())
}

#[derive(Serialize, Deserialize)]
struct EmbeddingRecord {
    id: String,
    embedding: Vec<f32>, // expected length: 768
    metadata: String,    // JSON string
}

/// Upsert an embedding record into the on-disk "transaction_embeddings" table.
pub fn upsert_embedding(db_path: &str, id: &str, embedding: &[f32], metadata: &str) -> Result<(), Box<dyn std::error::Error>> {
    if embedding.len() == 0 {
        return Err("embedding must not be empty".into());
    }

    let emb_dir = Path::new(db_path).join("transaction_embeddings");
    if !emb_dir.exists() {
        fs::create_dir_all(&emb_dir)?;
    }

    let record = EmbeddingRecord {
        id: id.to_string(),
        embedding: embedding.to_vec(),
        metadata: metadata.to_string(),
    };

    let file_path = emb_dir.join(format!("{}.json", id));
    let json = serde_json::to_vec(&record)?;
    let mut f = fs::File::create(&file_path)?;
    f.write_all(&json)?;
    Ok(())
}

/// Retrieve an embedding record by ID.
pub fn get_embedding(db_path: &str, id: &str) -> Result<(Vec<f32>, String), Box<dyn std::error::Error>> {
    let file_path = Path::new(db_path).join("transaction_embeddings").join(format!("{}.json", id));
    if !file_path.exists() {
        return Err(format!("embedding with id '{}' not found", id).into());
    }
    let mut f = fs::File::open(&file_path)?;
    let mut buf = Vec::new();
    f.read_to_end(&mut buf)?;
    let rec: EmbeddingRecord = serde_json::from_slice(&buf)?;
    Ok((rec.embedding, rec.metadata))
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    #[test]
    fn upsert_and_get_embedding_roundtrip() -> Result<(), Box<dyn std::error::Error>> {
        let mut dir = std::env::temp_dir();
        dir.push(format!("lumi_vector_db_emb_test_{}", std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH)?.as_millis()));
        let dir_str = dir.to_str().unwrap().to_string();

        // Cleanup if exists
        if dir.exists() {
            fs::remove_dir_all(&dir)?;
        }

        // Init
        vector_db_init(&dir_str)?;

        // Prepare dummy embedding of length 768
        let embedding = vec![0.5f32; 768];
        let metadata = r#"{"vendor":"Test Cafe","amount":4.25}"#;
        let id = "test-embed-1";

        // Upsert
        upsert_embedding(&dir_str, id, &embedding, metadata)?;

        // Retrieve
        let (got_embedding, got_metadata) = get_embedding(&dir_str, id)?;
        assert_eq!(got_embedding.len(), 768);
        // Check a few sample values
        assert!((got_embedding[0] - 0.5).abs() < 1e-6);
        assert_eq!(got_metadata, metadata.to_string());

        // Cleanup
        fs::remove_dir_all(&dir)?;
        Ok(())
    }
}
