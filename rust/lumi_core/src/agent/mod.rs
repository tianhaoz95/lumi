use crate::inference::{self, ModelTier, StreamSink, InferenceChunk};
use tokio::time::{timeout, Duration};

/// LumiAgent is a thin wrapper that will later integrate with Rig's Agent.
/// For Phase 3 scaffold it initializes the rig-core and provides a simple
/// completion helper that collects inference chunks into a single String.
#[derive(Debug, Clone)]
pub struct LumiAgent {
    pub id: String,
}

impl LumiAgent {
    /// Construct a new LumiAgent. Currently calls into the simple `rig-core`
    /// initialization helper and stores the returned id string.
    pub fn new() -> Self {
        let id = rig_core::init_agent();
        LumiAgent { id }
    }

    /// Asynchronously request a completion for `prompt` using the provided
    /// `ModelTier`. This function collects streamed `InferenceChunk`s from the
    /// inference module and concatenates tokens with spaces. A timeout is
    /// enforced to avoid hanging the caller.
    pub async fn complete(&self, prompt: String, tier: ModelTier) -> Result<String, String> {
        // Create a sink/receiver pair to observe inference stream chunks.
        let (mut sink, mut rx) = StreamSink::new_channel(16);

        // Start the inference stream (spawns background tasks internally).
        inference::infer_stream(prompt.clone(), tier, sink.clone())?;

        // Collect tokens until a final chunk or until timeout.
        let mut out = String::new();
        loop {
            // Wait for the next chunk with a per-chunk timeout to avoid indefinite waits.
            match timeout(Duration::from_secs(10), rx.recv()).await {
                Ok(Some(chunk)) => {
                    if !chunk.token.is_empty() {
                        if !out.is_empty() { out.push(' '); }
                        out.push_str(&chunk.token);
                    }
                    if chunk.is_final {
                        break;
                    }
                }
                Ok(None) => {
                    // Sender closed; finish collecting
                    break;
                }
                Err(_) => {
                    // Timeout waiting for chunk – return what we have so far.
                    break;
                }
            }
        }

        Ok(out)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn lumi_agent_new_returns_rig_id() {
        let agent = LumiAgent::new();
        assert_eq!(agent.id, "rig-initialized");
    }

    #[tokio::test]
    async fn lumi_agent_complete_collects_stream() {
        let agent = LumiAgent::new();
        let prompt = "hello world from lumi".to_string();
        let res = agent.complete(prompt, crate::inference::ModelTier::Sentinel).await;
        assert!(res.is_ok());
        let text = res.unwrap();
        // Since inference tokenization splits on whitespace, ensure expected words present
        assert!(text.contains("hello"));
        assert!(text.contains("lumi"));
    }
}
