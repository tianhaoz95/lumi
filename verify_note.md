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
