use std::fs;
use std::path::Path;

#[test]
fn gitignore_contains_expected_entries() {
    // Resolve repository root relative to this crate's manifest dir
    let manifest_dir = env!("CARGO_MANIFEST_DIR");
    let repo_root = Path::new(manifest_dir).join("../../");
    let gitignore_path = repo_root.join(".gitignore");
    let s = fs::read_to_string(&gitignore_path)
        .expect(&format!("Failed to read {}", gitignore_path.display()));

    assert!(s.contains(".env.test"), ".gitignore must contain .env.test");
    // Accept either explicit file entry or folder ignore
    assert!(s.contains(".vscode/mcp.json") || s.contains(".vscode/"), ".gitignore must ignore .vscode/mcp.json or the entire .vscode/ folder");
}
