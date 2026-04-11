use std::fs;
use std::path::PathBuf;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn mcp_template_exists_and_valid() {
        // CARGO_MANIFEST_DIR is rust/lumi_core
        let manifest = env!("CARGO_MANIFEST_DIR");
        let binding = PathBuf::from(manifest);
        let repo_root = binding
            .parent().expect("parent 1")
            .parent().expect("parent 2");
        let path = repo_root.join(".vscode").join("mcp.json.template");
        assert!(path.exists(), "mcp.json.template should exist at {:?}", path);
        let content = fs::read_to_string(&path).expect("read file");
        assert!(content.contains("APPWRITE_ENDPOINT"), "missing APPWRITE_ENDPOINT placeholder");
        assert!(content.contains("APPWRITE_PROJECT_ID"), "missing APPWRITE_PROJECT_ID placeholder");
        assert!(content.contains("APPWRITE_API_KEY"), "missing APPWRITE_API_KEY placeholder");
    }
}
