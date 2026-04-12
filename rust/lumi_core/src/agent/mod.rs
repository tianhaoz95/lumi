use crate::inference::{self, ModelTier, StreamSink, InferenceChunk};
use tokio::time::{timeout, Duration};
use async_trait::async_trait;
use serde::{Serialize, Deserialize};

/// LumiAgent is a thin wrapper that will later integrate with Rig's Agent.
/// For Phase 3 scaffold it initializes the rig-core and provides a simple
/// completion helper that collects inference chunks into a single String.
#[derive(Debug, Clone)]
pub struct LumiAgent {
    pub id: String,
}

impl LumiAgent {
    /// Construct a new LumiAgent. Register this agent as the rig-core
    /// CompletionProvider so higher-level code can call into Rig to obtain
    /// completions that are routed through LiteRT-LM.
    pub fn new() -> Self {
        let id = rig_core::init_agent();
        let agent = LumiAgent { id };
        // Register agent as the global completion provider. Ignore failure if
        // something has already registered a provider.
        let _ = rig_core::set_completion_provider(Box::new(agent.clone()));
        agent
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

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentChunk {
    pub token: String,
    pub is_final: bool,
    pub tokens_per_second: f32,
}

#[async_trait]
impl rig_core::CompletionProvider for LumiAgent {
    async fn complete(&self, prompt: String) -> Result<String, String> {
        // Route through Sentinel tier by default for short prompts. The real
        // ModelRouter will pick between tiers; keeping Sentinel here is a
        // conservative default.
        self.complete(prompt, crate::inference::ModelTier::Sentinel).await
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
        let lower = text.to_lowercase();
        assert!(lower.contains("hello"));
        assert!(lower.contains("lumi"));
    }

    #[tokio::test]
    async fn rig_core_can_call_registered_provider() {
        let _ = env_logger::builder().is_test(true).try_init();
        let agent = LumiAgent::new();
        // Call via rig-core API which should invoke the provider registered in new().
        let res = rig_core::call_complete("testing via rig-core".to_string()).await;
        assert!(res.is_ok());
        let out = res.unwrap();
        assert!(!out.is_empty());
    }
}
