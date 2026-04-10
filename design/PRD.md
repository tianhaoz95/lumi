# **❄️ Project Lumi: Master Design Specification v1.0**

**The Agentic, Local-First Financial Companion**

## **1\. Vision & Core Philosophy**

**Lumi** (Finnish for *Snow*) is a "Zero-Entry" bookkeeping app for 2026\. It transforms the "cold" complexity of financial tracking into a cozy, automated experience.

* **Privacy-First:** 100% on-device processing. No cloud uploads for PII.  
* **Intelligence-First:** Uses multimodal LLMs to "see" receipts and "reason" over financial context.  
* **Proactive:** A sentinel system that watches for gaps in your records so you don't have to.

## ---

**2\. Technical Stack (The "Glacier" Architecture)**

| Layer | Component | 2026 Technology |
| :---- | :---- | :---- |
| **Frontend** | **UI Framework** | **Flutter 3.x** (Impeller Renderer) |
|  | **Agentic UI** | **Flutter AI Toolkit** (Chat/Multimodal Input) |
|  | **Dynamic Display** | **GenUI SDK** (Model-driven Interactive Widgets) |
| **Bridge** | **Logic Conduit** | **FRB v2** (Streaming SSE, Rust/Dart async bridge) |
| **Orchestrator** | **Agentic Core** | **Rig (Rust)** (Memory, Tool-calling, RAG) |
| **Inference** | **Local Brain** | **LiteRT-LM** (NPU-accelerated runtime) |
|  | **Model (Tier 1\)** | **Gemma 4 E2B** (Background/Low-power "Sentinel") |
|  | **Model (Tier 2\)** | **Gemma 4 E4B** (Foreground/Complex "Auditor") |
| **Storage** | **Databases** | **SQLite** (Relational) \+ **LanceDB** (Vector/RAG) |

## ---

**3\. Agentic Design & Proactive Mechanisms**

### **🧠 The Rig Orchestrator**

Lumi uses **Rig** to manage "Tools" that the local LLM can call.

* **Short-term Memory:** Current conversation context (e.g., "I just mentioned this was a business trip").  
* **Long-term Memory (RAG):** LanceDB stores embeddings of past transactions, allowing the user to ask: *"Lumi, how much did I spend on heating last winter?"*

### **💓 Proactive Sentinel (Heartbeat)**

To keep the books "fresh," Lumi wakes up autonomously:

* **Heartbeat:** Every hour, BackgroundGuard wakes the **Gemma 4 E2B** model to scan for untagged transactions or missing receipts.  
* **Geofencing:** Uses flutter\_background\_geolocation. If the user leaves a known vendor location (e.g., Shell, Office Depot) without logging an entry, Lumi sends a soft notification: *"Just finished at Shell? Tap to snap your mileage and fuel receipt\!"*

## ---

**4\. Key Workflows**

* **Receipt Capture:** Multimodal OCR parses photos into structured JSON. GenUI renders a TransactionCard for instant verification.  
* **Mileage Tracking:** Infers distance from odometer photos \+ EXIF data. Calculates IRS 2026 deductions ($0.67/mile) automatically.  
* **OS Share Integration:** Screenshots shared to Lumi are parsed in the background. If a recurring subscription is detected, it is flagged for the user.

## ---

**5\. Implementation Roadmap**

### **Phase 1: The Permafrost (Foundation & Bridge)**

* **Tasks:** Initialize Flutter \+ FRB v2; Setup Rust Core with sea-orm (SQLite) and lance-db. Build base GenUI widgets.  
* **Success Criteria:** "Ping" latency between Dart/Rust \< 2ms; Mock data rendered via GenUI schema successfully.

### **Phase 2: The Thaw (On-Device Inference)**

* **Tasks:** Integrate LiteRT-LM in Rust; Load Gemma 4 E2B/E4B; Stream tokens to Flutter AI Toolkit.  
* **Success Criteria:** Model loads in \< 3s; Inference speed \> 25 tokens/sec on device NPU.

### **Phase 3: The Snowpack (Agentic Orchestration)**

* **Tasks:** Implement **Rig** agent with tools (log\_to\_db, query\_history); Setup local RAG pipeline.  
* **Success Criteria:** Agent correctly chooses the "Mileage Tool" when shown an odometer; RAG retrieves correct historical data 95% of the time.

### **Phase 4: The Sentinel (Proactive Layer)**

* **Tasks:** Implement BackgroundGuard heartbeat; Setup geofence triggers; Build "soft" notification logic.  
* **Success Criteria:** Background heartbeat uses \< 4% battery/day; Notifications trigger within 60s of leaving a geofence.

### **Phase 5: The Aurora (UX Polish & Audit)**

* **Tasks:** Apply "Cozy Cabin" theme; Animate **Kit the Fox** mascot; Implement SHA-256 audit trail and PDF export.  
* **Success Criteria:** Constant 120fps UI; Successful generation of a "Tax Evidence Report" with verifiable hashes.

## ---

**6\. Visual & Sensory Language**

* **Theme:** "Cozy Cabin" – Frosted glass, soft blues (\#E0F7FA), and "Snow White" surfaces.  
* **Mascot:** **Kit the Fox** – Guides the user through the chat. Digs through "snowbanks" during database searches.  
* **Haptics:** "Crunchy snow" profiles for confirmations; "Ice-click" for data locking.  
* **Privacy Guard:** A glowing "Local Shield" icon confirms all intelligence is staying on-device.

---

