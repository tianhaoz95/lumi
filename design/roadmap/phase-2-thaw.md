# Phase 2: Thaw — On-Device Inference

> **Goal:** Integrate LiteRT-LM into the Rust core, load Gemma 4 E2B and E4B models, stream generated tokens across the FRB v2 bridge to the Flutter AI Toolkit chat UI, and hit the performance targets: model load < 3 s and inference > 25 tokens/sec on the device NPU.

**Prerequisite:** Phase 1 acceptance criteria fully met.

---

## 1. LiteRT-LM Integration (Rust)

### 1.1 Dependency Setup

- [x] **1.1.1** Add `litert-lm` (Rust bindings) to `rust/Cargo.toml`. Pin to the version documented in the project wiki.
- [x] **1.1.2** Add build script (`build.rs`) to link the LiteRT native libraries for each platform target:
  - `aarch64-linux-android` (Android, NPU path)
  - `aarch64-apple-ios` (iOS, ANE path)
  - `x86_64-unknown-linux-gnu` (host, CPU fallback for CI)
- [x] **1.1.3** Verify `cargo build --target aarch64-linux-android` links successfully.

**Verifiable result:** `cargo build` passes on host; `flutter build apk` picks up native libs without linker errors.

### 1.2 Model File Management

- [x] **1.2.1** Download Gemma 4 E2B (quantized, `.task` / `.bin` format for LiteRT) and Gemma 4 E4B.
- [x] **1.2.2** Store model files outside the Flutter asset bundle (too large). Define a `ModelRegistry` in Rust that resolves model paths from the platform's application support directory.
- [x] **1.2.3** Implement `ModelDownloadService` exposed via FRB:
  - `check_model_ready(model_id: String) -> bool` — checks if model file exists and passes SHA-256 integrity check.
  - `get_download_progress() -> f32` — returns 0.0–1.0.
  - On first launch, if models are absent, stream download progress to Flutter for a loading screen.
- [x] **1.2.4** Document model file URLs and expected SHA-256 hashes in `design/models.md`.

**Tests:**
- Rust unit test: `check_model_ready()` returns `false` when file is missing, `true` when present with valid hash.
- Rust unit test: SHA-256 integrity check correctly rejects a corrupted file.

### 1.3 LiteRT-LM Runtime Initialization

- [x] **1.3.1** Create `InferenceEngine` struct in `rust/lumi_core/src/inference/mod.rs`:
  ```rust
  pub struct InferenceEngine {
      model_id: ModelId,  // E2B | E4B
      session: LiteRtSession,
  }
  ```
- [x] **1.3.2** Implement `InferenceEngine::load(model_id, model_path) -> Result<Self>`:
  - Preferentially enable NPU delegate (Android) / ANE delegate (iOS).
  - Fall back to GPU → CPU if hardware delegate unavailable.
  - Measure and log load time.
- [x] **1.3.3** Expose `load_model(model_id: String) -> Result<()>` via FRB. Call at app startup after `db_init()`.
- [x] **1.3.4** Create a `ModelTier` enum (`Sentinel = E2B`, `Auditor = E4B`) with a selection function based on task complexity hints passed from Dart.

**Tests:**
- Integration test: `load_model("e2b")` completes in < 3 s on a reference device (documented in test annotations).
- Rust unit test: falls back gracefully to CPU when NPU is unavailable (mocked delegate).

---

## 2. Token Streaming via FRB v2

### 2.1 Streaming API Design

- [x] **2.1.1** Define the FRB streaming interface in Rust:
  ```rust
  pub fn infer_stream(
      prompt: String,
      model_tier: ModelTier,
      sink: StreamSink<InferenceChunk>,
  ) -> Result<()>
  ```
  where `InferenceChunk` is:
  ```rust
  pub struct InferenceChunk {
      pub token: String,
      pub is_final: bool,
      pub tokens_per_second: f32,
  }
  ```
- [x] **2.1.2** Run `flutter_rust_bridge_codegen generate` to produce the streaming Dart bindings.
- [x] **2.1.3** In Dart, wrap the stream in a `ChatService` that exposes `Stream<InferenceChunk> chat(String prompt, ModelTier tier)`.

**Verifiable result:** A raw stream integration test sends a prompt and receives ≥ 1 `InferenceChunk` within 5 seconds on a real device.

### 2.2 Chat UI — Live Streaming

- [x] **2.2.1** Update `HomeScreen` to consume `ChatService.chat()`:
  - Display Kit's response bubble with a text that builds character-by-character as chunks arrive.
  - Show a "breathing" animation (pulsing dot) while streaming is in progress.
  - Freeze and finalize bubble when `is_final == true`.
- [x] **2.2.2** Display the live `tokens_per_second` metric in a dev-mode overlay (`kDebugMode` only).
- [x] **2.2.3** Disable the send button while a response is streaming; re-enable on completion or error.

**Tests:**
- Widget test: send button disables while `ChatService` stream is active.
- Widget test: bubble text grows incrementally on each stream event (mock stream).
- Widget test: error state shows "Lumi is resting…" message when stream throws.

### 2.3 Model Selector Logic

- [x] **2.3.1** Implement `ModelRouter` in Dart:
  - Default to `E2B` (Sentinel) for all chat messages.
  - Upgrade to `E4B` (Auditor) when the prompt contains keywords: `receipt`, `audit`, `analyze`, `deduction`, or the message length > 300 characters.
- [x] **2.3.2** Display a subtle indicator in the chat UI when `E4B` is active (a small "Auditor" badge next to Kit's avatar).

**Tests:**
- Unit test: `ModelRouter.select(prompt)` returns `E2B` for short casual prompts.
- Unit test: returns `E4B` for prompts containing "analyze my receipts".
- Unit test: returns `E4B` for prompts longer than 300 characters.

---

## 3. Multimodal Input — Receipt OCR

### 3.1 Image Capture Pipeline

- [x] **3.1.1** Add `image_picker` and `camera` packages to `pubspec.yaml`.
- [x] **3.1.2** In the chat input bar's `add` button, add a bottom sheet with options: "Camera", "Photo Library".
- [x] **3.1.3** On image selection, pass the raw bytes to a Rust function via FRB:
  ```rust
  pub fn process_receipt_image(image_bytes: Vec<u8>) -> Result<ReceiptData>
  ```
- [x] **3.1.4** In Rust, encode the image as a base64 data URI and inject it into the Gemma 4 E4B multimodal prompt template for OCR.

### 3.2 Structured Receipt Extraction

- [x] **3.2.1** Design the OCR prompt template in `rust/lumi_core/src/prompts/receipt_ocr.txt`:
  ```
  You are a receipt parser. Extract from this image:
  - vendor_name
  - total_amount (float)
  - currency (ISO 4217)
  - date (ISO 8601)
  - line_items: [{description, amount}]
  Respond only in valid JSON.
  ```
- [ ] **3.2.2** Parse the model's JSON output into a `ReceiptData` struct:
  ```rust
  pub struct ReceiptData {
      pub vendor_name: String,
      pub total_amount: f64,
      pub currency: String,
      pub date: String,
      pub line_items: Vec<LineItem>,
  }
  ```
- [ ] **3.2.3** Return `ReceiptData` to Flutter. Display a `TransactionCard` GenUI widget (Phase 3) for user verification. For now, show raw JSON in a dev preview card.

**Tests:**
- Rust unit test: parse a known JSON string into `ReceiptData` correctly.
- Rust unit test: model returns invalid JSON → `process_receipt_image` returns a structured `ParseError`.
- Integration test: given a sample receipt image asset, `process_receipt_image` returns a `ReceiptData` with non-empty `vendor_name` and `total_amount > 0`.

---

## 4. Model Loading UX

### 4.1 First-Launch Loading Screen

- [ ] **4.1.1** On first launch (models not ready), show a full-screen loading state:
  - Background: atmospheric blurred orbs.
  - Kit the Fox mascot at full opacity with a "digging through snowbanks" idle animation (lottie or Flutter animation).
  - Progress bar consuming `get_download_progress()` stream.
  - Label: "Lumi is preparing your sanctuary…"
- [ ] **4.1.2** After models are ready, transition to Login or Home with a 500 ms fade.

**Tests:**
- Widget test: `LoadingScreen` renders progress bar and updates value from mock stream.
- Widget test: navigates to `LoginScreen` after stream completes.

---

## Phase 2 — Acceptance Criteria

| # | Criterion | How to Verify |
|---|---|---|
| P2-1 | Gemma 4 E2B loads in < 3 s on reference device | Integration test with device annotation; measured load time logged |
| P2-2 | Inference throughput ≥ 25 tokens/sec on NPU | `tokens_per_second` field in `InferenceChunk`; integration test asserts avg ≥ 25 |
| P2-3 | Token stream renders live in chat UI | Widget test with mock stream; integration test on device |
| P2-4 | Receipt image → structured `ReceiptData` pipeline works end-to-end | Integration test with sample receipt asset |
| P2-5 | `ModelRouter` correctly selects E2B vs E4B | Unit tests for all routing rules |
| P2-6 | Model loading screen shows progress and transitions on completion | Widget tests |
| P2-7 | CPU fallback: app still infers (slower) on non-NPU CI runner | CI integration test with `--dart-define=USE_CPU_FALLBACK=true` |
