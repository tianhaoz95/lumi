## [**1.1.4** Expose `agent_chat(user_message: String, sink: StreamSink<AgentChunk>) -> Result<()>` via FRB to replace the raw `infer_stream` used in Phase 2.]
**Verdict:** FAILED
**Root cause:**
The implementation failed to compile due to a `StreamSink` type collision and missing dependencies. It also failed to satisfy the naming, type, and logical requirements of the task.

**Specific findings:**
- **Compilation Failure:** 90+ errors in `frb_generated.rs` and `agent/mod.rs`. `lumi_core` defines its own `StreamSink` which conflicts with the one expected by `flutter_rust_bridge`. `env_logger` is used in tests but missing from `Cargo.toml`.
- **Incorrect Naming:** The function is named `frb_agent_chat` instead of `agent_chat`.
- **Incorrect Types:** The function uses `InferenceChunk` instead of the requested `AgentChunk`.
- **Missing Definition:** `AgentChunk` is not defined anywhere in the codebase.
- **Incorrect Implementation:** `frb_agent_chat` simply routes to the Phase 2 `infer_stream` without using any agent-specific logic, failing to serve as a proper "replacement" as requested by the roadmap.

**Suggested fix:**
1. Add `env_logger = "0.10"` to `rust/lumi_core/Cargo.toml` as a dev-dependency.
2. Define `AgentChunk` in `rust/lumi_core/src/agent/mod.rs` (likely a struct containing `token`, `is_final`, etc.).
3. Fix the `StreamSink` collision by either renaming the internal placeholder in `inference/mod.rs` or properly using the `flutter_rust_bridge::StreamSink` for public-facing APIs.
4. Rename `frb_agent_chat` to `agent_chat`.
5. Update `agent_chat` to use `AgentChunk` and ensure it actually flows through the `LumiAgent` logic (even if currently thin, it should be the architectural entry point).

## [**1.2.1** Define the tool in Rust using Rig's #[tool] macro (or equivalent):]
**Verdict:** FAILED
**Root cause:**
The implementation is a plain Rust function that lacks the required Rig `#[tool]` macro and deviates from the specified return type. The supporting `rig-core` library also lacks the macro definition.

**Specific findings:**
- **Missing Macro:** `rust/lumi_core/src/tools.rs`: The `log_transaction` function is defined without the `#[tool]` attribute specified in the roadmap.
- **Type Mismatch:** `rust/lumi_core/src/tools.rs`: The return type is `Result<String, String>` instead of the roadmap's `Result<String>`.
- **Incomplete Scaffold:** `rust/rig-core/src/lib.rs`: The local Rig scaffold does not yet provide a `tool` macro, preventing proper tool definition.

**Suggested fix:**
1. Implement a (scaffold) `#[tool]` attribute macro in `rig-core` or a companion crate.
2. Apply `#[tool(description = "...")]` to `log_transaction` in `tools.rs`.
3. Align the return type with the roadmap specification.
- **Incomplete Testing:** `rust/lumi_core/src/tools.rs`: The tests only cover the `log_transaction_with_pool` internal helper, not the actual `log_transaction` tool wrapper specified in the roadmap.
