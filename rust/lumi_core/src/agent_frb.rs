use crate::inference::{self, InferenceChunk, StreamSink};
use crate::agent::LumiAgent;

/// FRB-facing agent chat entrypoint (scaffold)
/// Spawns a background task that runs the current inference stream and
/// forwards InferenceChunk -> AgentChunk into the provided sink.
pub fn agent_chat(prompt: String, mut sink: StreamSink<crate::agent::AgentChunk>) -> Result<(), String> {
    // Ensure an agent is registered (registers completion provider as a side-effect)
    let _agent = LumiAgent::new();

    flutter_rust_bridge::spawn(async move {
        // Create internal channel to observe inference chunks
        let (mut local_sink, mut rx) = crate::inference::StreamSink::new_channel(16);
        let _ = crate::inference::infer_stream(prompt, crate::inference::ModelTier::Sentinel, local_sink.clone());

        // Forward chunks from internal receiver to the FRB-provided sink
        while let Some(chunk) = rx.recv().await {
            let agent_chunk = crate::agent::AgentChunk {
                token: chunk.token,
                is_final: chunk.is_final,
                tokens_per_second: chunk.tokens_per_second,
            };
            let mut s = sink.clone();
            let _ = s.send(agent_chunk).await;
        }

        // Close the sink when done
        let _ = sink.close().await;
    });

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::inference::StreamSink;
    use tokio::time::{timeout, Duration};

    #[tokio::test]
    async fn agent_chat_streams_one_or_more_chunks() {
        let (mut sink, mut rx) = StreamSink::new_channel(16);
        // call the FRB-facing function which spawns a background task
        agent_chat("hello test from agent".to_string(), sink).expect("agent_chat should return Ok");

        let mut collected = String::new();
        loop {
            match timeout(Duration::from_secs(2), rx.recv()).await {
                Ok(Some(chunk)) => {
                    if !chunk.token.is_empty() {
                        if !collected.is_empty() { collected.push(' '); }
                        collected.push_str(&chunk.token);
                    }
                    if chunk.is_final { break; }
                }
                Ok(None) => break,
                Err(_) => break,
            }
        }

        assert!(collected.contains("hello") || !collected.is_empty(), "Expected at least one token or hello present");
    }
}
