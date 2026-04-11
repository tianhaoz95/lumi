use async_trait::async_trait;
use once_cell::sync::OnceCell;

#[async_trait]
pub trait CompletionProvider: Send + Sync + 'static {
    async fn complete(&self, prompt: String) -> Result<String, String>;
}

static COMPLETION_PROVIDER: OnceCell<Box<dyn CompletionProvider>> = OnceCell::new();

/// Register the global completion provider. Returns true on success and false
/// if a provider was already registered.
pub fn set_completion_provider(provider: Box<dyn CompletionProvider>) -> bool {
    COMPLETION_PROVIDER.set(provider).is_ok()
}

/// Call the registered completion provider, if present.
pub async fn call_complete(prompt: String) -> Result<String, String> {
    if let Some(p) = COMPLETION_PROVIDER.get() {
        p.complete(prompt).await
    } else {
        Err("no completion provider registered".to_string())
    }
}

/// Initialize rig agent runtime and return an agent id string. Kept for
/// backwards compatibility with earlier scaffolding.
pub fn init_agent() -> String {
    "rig-initialized".to_string()
}

#[cfg(test)]
mod tests {
    use super::*;
    use async_trait::async_trait;

    struct Dummy;
    #[async_trait]
    impl CompletionProvider for Dummy {
        async fn complete(&self, prompt: String) -> Result<String, String> {
            Ok(format!("echo: {}", prompt))
        }
    }

    #[tokio::test]
    async fn register_and_call_provider() {
        let _ = set_completion_provider(Box::new(Dummy));
        let res = call_complete("hi".to_string()).await.unwrap();
        assert_eq!(res, "echo: hi");
    }
}
