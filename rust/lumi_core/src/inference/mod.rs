// Inference module stub for Phase 2 tasks
// Provides a minimal InferenceEngine struct and supporting types so the
// rest of the crate can compile and unit tests can exercise construction.

use std::fmt;

/// Model identifier (E2B = Sentinel, E4B = Auditor)
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ModelId {
    E2B,
    E4B,
}

impl From<&str> for ModelId {
    fn from(s: &str) -> Self {
        match s.to_lowercase().as_str() {
            "e4b" | "auditor" => ModelId::E4B,
            _ => ModelId::E2B,
        }
    }
}

impl fmt::Display for ModelId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            ModelId::E2B => write!(f, "e2b"),
            ModelId::E4B => write!(f, "e4b"),
        }
    }
}

/// Abstract model tier used for routing decisions. Sentinel == E2B (lightweight),
/// Auditor == E4B (heavy-weight analysis).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ModelTier {
    Sentinel,
    Auditor,
}

impl fmt::Display for ModelTier {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            ModelTier::Sentinel => write!(f, "Sentinel"),
            ModelTier::Auditor => write!(f, "Auditor"),
        }
    }
}

impl From<ModelTier> for ModelId {
    fn from(t: ModelTier) -> Self {
        match t {
            ModelTier::Sentinel => ModelId::E2B,
            ModelTier::Auditor => ModelId::E4B,
        }
    }
}

/// Selection function used by the Dart side to pick an appropriate model tier
/// based on lightweight hints about task complexity. Hints are free-form tags
/// such as `"receipt"`, `"analyze"`, or `"length>350"`.
pub fn select_model_tier_from_hints(hints: Vec<String>) -> ModelTier {
    // Keywords that require the Auditor (E4B)
    const AUDITOR_KEYWORDS: [&str; 4] = ["receipt", "audit", "analyze", "deduction"];

    for h in &hints {
        let s = h.to_lowercase();
        for kw in &AUDITOR_KEYWORDS {
            if s.contains(kw) {
                return ModelTier::Auditor;
            }
        }
        // Simple length hint parser: "length>300"
        if let Some(rest) = s.strip_prefix("length>") {
            if let Ok(n) = rest.parse::<usize>() {
                if n > 300 {
                    return ModelTier::Auditor;
                }
            }
        }
    }

    // Default to Sentinel (E2B)
    ModelTier::Sentinel
}

/// FRB-friendly wrapper returning a String for easier Dart consumption.
pub fn frb_select_model_tier(hints: Vec<String>) -> String {
    select_model_tier_from_hints(hints).to_string()
}

/// A lightweight stub representing a LiteRT session/delegate. In the real
/// implementation this will wrap the actual LiteRT runtime session and
/// hardware delegates (NPU/ANE/GPU/CPU). For Phase 1/2 scaffolding, keep it
/// minimal and testable.
#[derive(Debug)]
pub struct LiteRtSession {
    pub backend: String, // e.g., "npu", "gpu", "cpu"
}

impl LiteRtSession {
    pub fn new(backend: &str) -> Self {
        LiteRtSession {
            backend: backend.to_string(),
        }
    }
}

/// The InferenceEngine holds the chosen model id and the underlying runtime
/// session. Later tasks will add loading, streaming and delegate logic.
pub struct InferenceEngine {
    pub model_id: ModelId,
    pub session: LiteRtSession,
}

impl InferenceEngine {
    /// Construct a new InferenceEngine from a ModelId and a LiteRtSession.
    /// This is intentionally simple for the scaffolded implementation.
    pub fn new(model_id: ModelId, session: LiteRtSession) -> Self {
        InferenceEngine { model_id, session }
    }

    /// Helper to construct from string id and backend name (convenience for tests)
    pub fn from_strings(model: &str, backend: &str) -> Self {
        InferenceEngine::new(ModelId::from(model), LiteRtSession::new(backend))
    }

    /// Load a model from a filesystem path and construct an InferenceEngine.
    ///
    /// Performs a simple existence check of the model file and chooses a
    /// preferred backend based on environment hints. This is a conservative
    ///, testable implementation; real delegate initialization happens later.
    pub fn load(model_id: &str, model_path: &str) -> Result<Self, Box<dyn std::error::Error + Send + Sync>> {
        use std::path::Path;
        let p = Path::new(model_path);
        if !p.exists() {
            return Err(format!("model file not found: {}", model_path).into());
        }

        let backend = if cfg!(target_os = "android") && std::env::var("LUMI_ENABLE_NPU").ok().as_deref() == Some("1") {
            "npu"
        } else if std::env::var("LUMI_ENABLE_GPU").ok().as_deref() == Some("1") {
            "gpu"
        } else {
            "cpu"
        };

        let session = LiteRtSession::new(backend);
        Ok(InferenceEngine { model_id: ModelId::from(model_id), session })
    }
}

// Global holder for the loaded inference engine. Stores the engine after FRB load.
static GLOBAL_ENGINE: once_cell::sync::Lazy<std::sync::Mutex<Option<InferenceEngine>>> =
    once_cell::sync::Lazy::new(|| std::sync::Mutex::new(None));

/// FRB-friendly wrapper to load a model and store it globally for later inference calls.
/// Returns Ok(()) on success, Err(String) on failure.
pub fn frb_load_model(model_id: String) -> Result<(), String> {
    // Determine base directory for models (env override -> platform data dir -> temp)
    let base: std::path::PathBuf = if let Ok(dir) = std::env::var("LUMI_MODEL_DIR") {
        std::path::PathBuf::from(dir)
    } else if let Some(proj) = directories::ProjectDirs::from("com", "lumi", "Lumi") {
        proj.data_dir().to_path_buf()
    } else {
        std::env::temp_dir()
    };

    let model_path = base.join(format!("{}.bin", model_id));
    let model_path_str = model_path
        .to_str()
        .ok_or_else(|| "invalid model path".to_string())?;

    match InferenceEngine::load(&model_id, model_path_str) {
        Ok(engine) => {
            let mut guard = GLOBAL_ENGINE
                .lock()
                .map_err(|e| format!("failed to lock global engine: {}", e))?;
            *guard = Some(engine);
            Ok(())
        }
        Err(e) => Err(format!("failed to load model: {}", e)),
    }
}

// ----------------------
// FRB Streaming Interface
// ----------------------

use serde::{Serialize, Deserialize};
use std::sync::Arc;
use tokio::sync::mpsc;

/// Local StreamSink placeholder used in the FRB streaming scaffold. In the
/// real FRB integration this would be `flutter_rust_bridge::StreamSink<T>`.
#[derive(Clone)]
pub struct StreamSink<T: Send + 'static> {
    sender: Arc<mpsc::Sender<T>>,
}

impl<T: Send + 'static> StreamSink<T> {
    /// Create a new StreamSink and return it along with the Receiver side so
    /// tests can observe emitted items.
    pub fn new_channel(buffer: usize) -> (Self, mpsc::Receiver<T>) {
        let (tx, rx) = mpsc::channel(buffer);
        (StreamSink { sender: Arc::new(tx) }, rx)
    }

    pub async fn send(&mut self, v: T) -> Result<(), ()> {
        // Use try_send to avoid awaiting if receiver is closed
        self.sender.send(v).await.map_err(|_| ())
    }

    pub async fn close(&mut self) -> Result<(), ()> {
        // Dropping the sender will close the channel for receivers
        Ok(())
    }
}


/// Chunk of inference output sent over FRB to Dart.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InferenceChunk {
    pub token: String,
    pub is_final: bool,
    pub tokens_per_second: f32,
}

/// Internal helper: stream prompt tokens to a vector of chunks. Used by both
/// tests and the FRB-facing `infer_stream` function.
async fn stream_prompt_to_chunks(prompt: String, _model_tier: ModelTier) -> Vec<InferenceChunk> {
    // Simple tokenization: split on whitespace for Phase 2 scaffold.
    let tokens: Vec<String> = if prompt.is_empty() {
        vec!["".to_string()]
    } else {
        prompt.split_whitespace().map(|s| s.to_string()).collect()
    };

    let mut out: Vec<InferenceChunk> = Vec::new();
    let start = tokio::time::Instant::now();
    for (i, t) in tokens.into_iter().enumerate() {
        let elapsed = start.elapsed().as_secs_f32().max(0.0001);
        let tps = (i as f32 + 1.0) / elapsed;
        let chunk = InferenceChunk {
            token: t,
            is_final: false,
            tokens_per_second: tps,
        };
        out.push(chunk);
        // Small delay to simulate streaming
        tokio::time::sleep(tokio::time::Duration::from_millis(20)).await;
    }

    // Final chunk indicating completion
    let final_chunk = InferenceChunk {
        token: String::new(),
        is_final: true,
        tokens_per_second: 0.0,
    };
    out.push(final_chunk);
    out
}

/// FRB-exposed streaming function. Dart will receive a stream of
/// `InferenceChunk` items. This function spawns a background task so the
/// FRB call can return immediately while the stream continues.
pub fn infer_stream(prompt: String, model_tier: ModelTier, mut sink: StreamSink<InferenceChunk>) -> Result<(), String> {
    // Move values into async task
    flutter_rust_bridge::spawn(async move {
        // Generate the chunks
        let chunks = stream_prompt_to_chunks(prompt, model_tier).await;
        // Send each chunk into the sink; ignore send errors
        for mut chunk in chunks {
            let mut s = sink.clone();
            flutter_rust_bridge::spawn(async move {
                let _ = s.send(chunk).await;
            });
            // small pacing to avoid saturating the runtime
            tokio::time::sleep(tokio::time::Duration::from_millis(5)).await;
        }

        // Close the sink when done. Best-effort; ignore errors.
        let _ = sink.close().await;
    });

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs::File;
    use std::io::Write;
    use std::env;

    #[test]
    fn inference_engine_constructs_with_defaults() {
        let eng = InferenceEngine::from_strings("e2b", "cpu");
        assert_eq!(eng.model_id, ModelId::E2B);
        assert_eq!(eng.session.backend, "cpu");
    }

    #[test]
    fn modelid_from_str_parses_e4b() {
        let m: ModelId = ModelId::from("E4B");
        assert_eq!(m, ModelId::E4B);
    }

    #[test]
    fn litert_session_new_sets_backend() {
        let s = LiteRtSession::new("npu");
        assert_eq!(s.backend, "npu");
    }

    #[test]
    fn load_returns_error_when_file_missing() {
        let tmp = env::temp_dir().join(format!("lumi_infer_missing_{}", std::process::id()));
        let _ = std::fs::remove_dir_all(&tmp);
        std::fs::create_dir_all(&tmp).unwrap();
        let missing_path = tmp.join("no_model.bin");
        let res = InferenceEngine::load("e2b", missing_path.to_str().unwrap());
        assert!(res.is_err(), "Expected error when model file is missing");
        let _ = std::fs::remove_dir_all(&tmp);
    }

    #[test]
    fn load_succeeds_and_selects_cpu_by_default() {
        let tmp = env::temp_dir().join(format!("lumi_infer_ok_{}", std::process::id()));
        let _ = std::fs::remove_dir_all(&tmp);
        std::fs::create_dir_all(&tmp).unwrap();
        let model_path = tmp.join("e2b.bin");
        let mut f = File::create(&model_path).unwrap();
        f.write_all(b"dummy-model").unwrap();

        env::remove_var("LUMI_ENABLE_NPU");
        env::remove_var("LUMI_ENABLE_GPU");

        let engine = InferenceEngine::load("e2b", model_path.to_str().unwrap()).expect("load should succeed");
        assert_eq!(engine.model_id, ModelId::E2B);
        assert_eq!(engine.session.backend, "cpu");

        let _ = std::fs::remove_dir_all(&tmp);
    }

    #[test]
    fn load_prefers_gpu_when_env_set() {
        let tmp = env::temp_dir().join(format!("lumi_infer_gpu_{}", std::process::id()));
        let _ = std::fs::remove_dir_all(&tmp);
        std::fs::create_dir_all(&tmp).unwrap();
        let model_path = tmp.join("e2b.bin");
        let mut f = File::create(&model_path).unwrap();
        f.write_all(b"dummy-model").unwrap();

        env::set_var("LUMI_ENABLE_GPU", "1");
        env::remove_var("LUMI_ENABLE_NPU");

        let engine = InferenceEngine::load("e2b", model_path.to_str().unwrap()).expect("load should succeed");
        assert_eq!(engine.session.backend, "gpu");

        env::remove_var("LUMI_ENABLE_GPU");
        let _ = std::fs::remove_dir_all(&tmp);
    }

    #[test]
    fn load_prefers_npu_on_android_hint() {
        let tmp = env::temp_dir().join(format!("lumi_infer_npu_{}", std::process::id()));
        let _ = std::fs::remove_dir_all(&tmp);
        std::fs::create_dir_all(&tmp).unwrap();
        let model_path = tmp.join("e2b.bin");
        let mut f = File::create(&model_path).unwrap();
        f.write_all(b"dummy-model").unwrap();

        env::set_var("LUMI_ENABLE_NPU", "1");

        let engine = InferenceEngine::load("e2b", model_path.to_str().unwrap()).expect("load should succeed");
        if cfg!(target_os = "android") {
            assert_eq!(engine.session.backend, "npu");
        } else {
            assert!(engine.session.backend == "cpu" || engine.session.backend == "gpu");
        }

        env::remove_var("LUMI_ENABLE_NPU");
        let _ = std::fs::remove_dir_all(&tmp);
    }

    #[test]
    fn frb_load_model_stores_engine() {
        let tmp = env::temp_dir().join(format!("lumi_frb_model_{}", std::process::id()));
        let _ = std::fs::remove_dir_all(&tmp);
        std::fs::create_dir_all(&tmp).unwrap();
        let model_path = tmp.join("e2b.bin");
        let mut f = File::create(&model_path).unwrap();
        f.write_all(b"dummy-model").unwrap();

        std::env::set_var("LUMI_MODEL_DIR", tmp.to_str().unwrap());
        let res = frb_load_model("e2b".to_string());
        assert!(res.is_ok(), "frb_load_model should succeed when file exists");

        std::env::remove_var("LUMI_MODEL_DIR");
        let _ = std::fs::remove_dir_all(&tmp);
    }

    #[test]
    fn select_model_tier_prefers_auditor_for_receipt_keyword() {
        let hints = vec!["receipt".to_string()];
        let tier = select_model_tier_from_hints(hints);
        assert_eq!(tier, ModelTier::Auditor);
    }

    #[test]
    fn select_model_tier_defaults_to_sentinel() {
        let hints: Vec<String> = vec![];
        let tier = select_model_tier_from_hints(hints);
        assert_eq!(tier, ModelTier::Sentinel);
    }

    #[tokio::test]
    async fn stream_prompt_to_chunks_emits_chunks() {
        let prompt = "hello world from lumi".to_string();
        let chunks = stream_prompt_to_chunks(prompt, ModelTier::Sentinel).await;

        // Should emit at least one non-final chunk and a final chunk
        assert!(chunks.len() >= 1, "expected at least one chunk");
        assert!(chunks.iter().any(|c| c.is_final), "expected a final chunk");
    }

    #[tokio::test]
    async fn frb_infer_stream_sends_chunks_via_sink() {
        use tokio::time::{timeout, Duration};
        let prompt = "lumi stream test".to_string();
        // Create a sink and receiver pair
        let (sink, mut rx) = StreamSink::new_channel(8);

        // Call infer_stream which spawns background tasks and returns immediately
        let res = infer_stream(prompt, ModelTier::Sentinel, sink.clone());
        assert!(res.is_ok(), "infer_stream should return Ok(())");

        // Expect at least one chunk from the receiver within 5 seconds
        match timeout(Duration::from_secs(5), rx.recv()).await {
            Ok(Some(chunk)) => {
                // We received a chunk; ensure it has the expected fields
                assert!(chunk.tokens_per_second >= 0.0);
                // token may be empty for final chunk, but presence is sufficient
            }
            Ok(None) => panic!("Channel closed without sending chunks"),
            Err(_) => panic!("Timed out waiting for inference chunk")
        }
    }
}

