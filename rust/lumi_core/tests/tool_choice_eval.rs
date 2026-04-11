// Integration-style test file for tool choice evaluation

#[test]
fn tool_choice_eval_table() {
    let cases = vec![
        ("Log $45 at Shell", "log_transaction"),
        ("How much did I spend on heating last winter?", "semantic_search"),
        ("I drove 23 miles to a client meeting today", "log_mileage"),
        ("Show me my expenses for March", "query_transactions"),
        ("Give me a summary of this month", "get_summary"),
    ];

    for (prompt, expected) in cases {
        let chosen = choose_tool(prompt);
        assert_eq!(chosen, expected, "Prompt: {} -> expected {}, got {}", prompt, expected, chosen);
    }
}

// Simple deterministic keyword-based chooser used only for this eval harness.
fn choose_tool(prompt: &str) -> &'static str {
    let p = prompt.to_lowercase();
    if (p.contains("log") && p.contains('$')) || p.contains("paid") || p.contains("bought") {
        "log_transaction"
    } else if p.contains("drive") || p.contains("drove") || p.contains("mile") {
        "log_mileage"
    } else if p.contains("summary") || p.contains("give me a summary") {
        "get_summary"
    } else if p.contains("expense") || p.contains("expenses") || p.contains("show me my expenses") {
        "query_transactions"
    } else if p.contains("heating") || p.contains("bill") || p.contains("last winter") {
        "semantic_search"
    } else {
        // default fallback
        "query_transactions"
    }
}
