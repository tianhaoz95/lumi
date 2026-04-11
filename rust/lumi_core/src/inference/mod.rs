//! Inference engine shim using the LiteRT-LM bindings (stubbed during tests)

pub struct InferenceEngine {
    pub model_id: String,
    pub session: litert_lm::LiteRtSession,
}

impl InferenceEngine {
    /// Load a model and return an initialized InferenceEngine.
    pub fn load(model_id: &str, model_path: &str) -> Result<Self, String> {
        let session = litert_lm::load_model(model_path)?;
        Ok(Self { model_id: model_id.to_string(), session })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn load_inference_engine_stub() {
        let r = InferenceEngine::load("E2B", "./models/gemma-e2b.task");
        assert!(r.is_ok());
        let engine = r.unwrap();
        assert_eq!(engine.model_id, "E2B");
    }
}
