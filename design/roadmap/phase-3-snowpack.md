# Phase 3: Snowpack — Agentic Orchestration

> **Goal:** Wire the Rig agent in Rust with a set of callable tools, connect it to SQLite and LanceDB, build the local RAG pipeline, and replace all mock data in the Flutter UI with real, persisted financial data. By the end of this phase, the agent correctly chooses the right tool for each task and RAG retrieves historical data with ≥ 95% accuracy.

**Prerequisite:** Phase 2 acceptance criteria fully met.

---

## 1. Rig Agent Setup

### 1.1 Rig Dependency & Agent Core

- [x] **1.1.1** Add `rig-core` to `rust/Cargo.toml`.
- [ ] **1.1.2** Create `rust/lumi_core/src/agent/mod.rs` with a `LumiAgent` struct that wraps a Rig `Agent` configured to use the local `InferenceEngine` as its completion provider (a custom `rig::completion::CompletionModel` impl backed by LiteRT-LM).
- [ ] **1.1.3** Implement the custom completion provider:
  - `complete(prompt: CompletionRequest) -> CompletionResponse` — routes through `InferenceEngine::infer_stream()` and collects the full response.
  - Passes the full tool-calling schema as part of the system prompt (Rig handles formatting).
- [ ] **1.1.4** Expose `agent_chat(user_message: String, sink: StreamSink<AgentChunk>) -> Result<()>` via FRB to replace the raw `infer_stream` used in Phase 2.

**Verifiable result:** Calling `agent_chat("hello")` from Dart receives a streamed response from the Rig agent (no tool call needed) within the same latency window as Phase 2 direct inference.

### 1.2 Tool: `log_transaction`

- [ ] **1.2.1** Define the tool in Rust using Rig's `#[tool]` macro (or equivalent):
  ```rust
  #[tool(description = "Log a financial transaction to the local database")]
  async fn log_transaction(
      vendor: String,
      amount: f64,
      currency: String,
      category: String,
      date: String,
      receipt_path: Option<String>,
  ) -> Result<String>
  ```
- [ ] **1.2.2** Implementation: insert a row into the `transactions` SQLite table, compute SHA-256 hash of the transaction JSON, store hash in `sha256_hash` column, return the new row ID.
- [ ] **1.2.3** Embed the new transaction into LanceDB (`embed_transaction` helper, see §3).

**Tests:**
- Rust unit test: `log_transaction` with valid inputs inserts a row and returns an ID.
- Rust unit test: SHA-256 is non-empty and deterministic for the same input.
- Rust unit test: duplicate transaction (same vendor + amount + date) returns the existing ID (idempotency).

### 1.3 Tool: `query_transactions`

- [ ] **1.3.1** Define tool:
  ```rust
  #[tool(description = "Query past transactions with optional filters")]
  async fn query_transactions(
      category: Option<String>,
      date_from: Option<String>,
      date_to: Option<String>,
      limit: Option<u32>,
  ) -> Result<Vec<TransactionSummary>>
  ```
- [ ] **1.3.2** Implementation: build a sea-orm `SelectStatement` from the provided filters and return matching rows as `Vec<TransactionSummary>`.

**Tests:**
- Rust unit test: empty filter returns all rows (up to default limit 50).
- Rust unit test: `category = "utilities"` returns only utility transactions.
- Rust unit test: `date_from` / `date_to` filter is inclusive and correct.

### 1.4 Tool: `log_mileage`

- [ ] **1.4.1** Define tool:
  ```rust
  #[tool(description = "Log a mileage entry and calculate IRS deduction")]
  async fn log_mileage(
      distance_miles: f64,
      start_location: String,
      end_location: String,
      date: String,
      purpose: String,
  ) -> Result<MileageLogResult>
  ```
- [ ] **1.4.2** Implementation: calculate deduction at IRS 2026 rate ($0.67/mile), insert into `mileage_logs`, return a `MileageLogResult` with `deduction_amount`.

**Tests:**
- Rust unit test: `log_mileage(10.0, ...)` returns `deduction_amount == 6.70`.
- Rust unit test: mileage row is persisted and retrievable.

### 1.5 Tool: `semantic_search`

- [ ] **1.5.1** Define tool:
  ```rust
  #[tool(description = "Search transaction history semantically using natural language")]
  async fn semantic_search(
      query: String,
      top_k: Option<u32>,
  ) -> Result<Vec<TransactionSummary>>
  ```
- [ ] **1.5.2** Implementation: embed the query string using the E2B model's embedding layer, query LanceDB for the top-k nearest neighbours, join results with SQLite for full transaction data.

**Tests:**
- Rust integration test: after seeding 20 transactions, `semantic_search("heating bills")` returns the correct utility transactions in the top 3.
- Rust unit test: `top_k` defaults to 5 when not provided.

### 1.6 Tool: `get_summary`

- [ ] **1.6.1** Define tool:
  ```rust
  #[tool(description = "Return a financial summary for a given period")]
  async fn get_summary(period: String) -> Result<FinancialSummary>
  ```
  where `period` is e.g. `"this_month"`, `"last_month"`, `"ytd"`.
- [ ] **1.6.2** Implementation: aggregate SQLite queries for total expenses, top categories, mileage deduction, and working hours logged.

**Tests:**
- Rust unit test: `get_summary("this_month")` returns correct totals for a seeded dataset.
- Rust unit test: unknown `period` string returns a descriptive error.

---

## 2. Agent Tool-Choice Accuracy

### 2.1 Prompt Engineering

- [ ] **2.1.1** Write the Rig system prompt in `rust/lumi_core/src/prompts/system.txt`:
  - Establishes Kit the Fox persona.
  - Lists all tools with clear descriptions.
  - Instructs to always prefer a tool call over a guessed answer when financial data is involved.
  - Instructs to ask clarifying questions if tool parameters are ambiguous.
- [ ] **2.1.2** Add few-shot examples to the system prompt for each tool.
- [ ] **2.1.3** Set a maximum of 5 tool-call iterations per conversation turn to prevent infinite loops.

### 2.2 Tool-Choice Evaluation Suite

- [ ] **2.2.1** Create `rust/lumi_core/tests/tool_choice_eval.rs` with a table of (prompt → expected_tool) pairs:

  | Prompt | Expected Tool |
  |---|---|
  | "Log $45 at Shell" | `log_transaction` |
  | "How much did I spend on heating last winter?" | `semantic_search` |
  | "I drove 23 miles to a client meeting today" | `log_mileage` |
  | "Show me my expenses for March" | `query_transactions` |
  | "Give me a summary of this month" | `get_summary` |

- [ ] **2.2.2** The eval test asserts correct tool choice for all entries. All must pass before Phase 3 is complete.

**Verifiable result:** `cargo test tool_choice_eval` passes with 100% accuracy on the eval table.

---

## 3. RAG Pipeline

### 3.1 Embedding Generation

- [ ] **3.1.1** Implement `embed_text(text: String) -> Result<Vec<f32>>` in Rust using the E2B model's embedding output (dimension: 768).
- [ ] **3.1.2** Create `embed_transaction(tx: &Transaction) -> Result<Vec<f32>>` that builds an embedding from: `"{vendor} {category} {amount} {date}"`.
- [ ] **3.1.3** Backfill: on first run after upgrade, embed all existing transactions and insert into LanceDB.

**Tests:**
- Rust unit test: `embed_text("coffee shop")` returns a vector of length 768.
- Rust unit test: two semantically similar texts produce cosine similarity > 0.85.
- Rust unit test: two semantically unrelated texts produce cosine similarity < 0.5.

### 3.2 LanceDB Write Path

- [ ] **3.2.1** Implement `upsert_embedding(id: String, vector: Vec<f32>, metadata: String)` that inserts or updates a row in LanceDB's `transaction_embeddings` table.
- [ ] **3.2.2** Call `upsert_embedding` automatically at the end of `log_transaction`.

**Tests:**
- Rust unit test: `upsert_embedding` succeeds and the row is retrievable by ID.
- Rust unit test: calling twice with the same ID updates rather than duplicates.

### 3.3 LanceDB Read Path (ANN Search)

- [ ] **3.3.1** Implement `vector_search(query_vector: Vec<f32>, top_k: u32) -> Result<Vec<SearchResult>>` using LanceDB's approximate nearest neighbour index.
- [ ] **3.3.2** Build LanceDB IVF-PQ index on `transaction_embeddings` after each batch of ≥ 100 new entries.

**Tests:**
- Rust integration test: seed 50 transactions. Query `"fuel"` embedding. Assert ≥ 1 Shell/gas-station transaction in top 3.
- Rust integration test: query for a vendor that doesn't exist returns an empty result set (not an error).

### 3.4 RAG Accuracy Evaluation

- [ ] **3.4.1** Create `rust/lumi_core/tests/rag_eval.rs` with 20 (query → expected transaction IDs) pairs from a seeded dataset.
- [ ] **3.4.2** Assert that the expected transaction appears in the top-5 results for ≥ 19/20 queries (≥ 95% recall@5).

**Verifiable result:** `cargo test rag_eval` reports ≥ 95% recall.

---

## 4. Flutter UI — Live Data

### 4.1 Dashboard — Real Metrics

- [ ] **4.1.1** Replace hardcoded mock values in `DashboardScreen` with data from `agent_chat` or direct FRB calls to `get_summary("this_month")`:
  - **Current Expenses**: `FinancialSummary.total_expenses`
  - **Working Hours**: future placeholder (not yet tracked; show `--`)
  - **Mileage Tracking**: `FinancialSummary.total_miles` + `estimated_deduction`
- [ ] **4.1.2** Replace mock **Recent Activity** list with a live query: `query_transactions(limit: 5)`.
- [ ] **4.1.3** Add a pull-to-refresh gesture that re-queries the Rust core.

**Tests:**
- Widget test: `DashboardScreen` renders live data from a mock FRB service.
- Widget test: pull-to-refresh triggers a re-query.
- Widget test: empty state ("No transactions yet") renders when list is empty.

### 4.2 GenUI — TransactionCard

- [ ] **4.2.1** Implement `TransactionCard` widget with fields:
  - Vendor icon (Material Symbol based on category mapping).
  - Vendor name + category label + date.
  - Amount (negative = expense in `on-surface`, positive = credit in `primary`).
  - AI-auto-tagged badge ("AI" chip in `primary-fixed` background) when `is_tagged == true`.
  - Edit button → inline edit form.
- [ ] **4.2.2** After receipt OCR (Phase 2), render a `TransactionCard` for user confirmation before saving.
- [ ] **4.2.3** "Confirm" → calls `log_transaction` tool. "Edit" → opens field editors. "Dismiss" → discards.

**Tests:**
- Widget test: `TransactionCard` shows AI badge when `is_tagged = true`.
- Widget test: amount color is `primary` for positive, `on-surface` for negative.
- Widget test: Confirm button calls the provided `onConfirm` callback.

### 4.3 Chat — Context-Aware Responses

- [ ] **4.3.1** Update `HomeScreen` to use `agent_chat()` (Rig-backed) instead of raw `infer_stream()`.
- [ ] **4.3.2** When the agent calls a tool and returns data, render the result as an **InsightCard** in the chat:
  - A `LumiCard`-styled widget with a summary table or chart.
  - For `get_summary` results: mini bar chart of top spending categories.
  - For `query_transactions` results: compact `TransactionCard` list.

**Tests:**
- Widget test: after `agent_chat` emits a tool-result chunk, the correct `InsightCard` variant renders.
- Widget test: `InsightCard` with `get_summary` data renders a category list.

---

## Phase 3 — Acceptance Criteria

| # | Criterion | How to Verify |
|---|---|---|
| P3-1 | Agent selects correct tool for 100% of eval prompts | `cargo test tool_choice_eval` all pass |
| P3-2 | RAG retrieval recall@5 ≥ 95% | `cargo test rag_eval` reports ≥ 19/20 |
| P3-3 | `log_transaction` persists to SQLite + LanceDB | Rust integration test |
| P3-4 | Dashboard shows real financial data from Rust core | Widget test with mock FRB; manual smoke test on device |
| P3-5 | Receipt OCR → `TransactionCard` confirmation flow works | Integration test with sample receipt image |
| P3-6 | Chat uses Rig agent (tool-calling capable) | Smoke test: ask "log $10 at Starbucks" → transaction appears in dashboard |
| P3-7 | SHA-256 hash stored for every logged transaction | Rust unit test + DB inspection |
