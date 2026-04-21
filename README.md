┌─────────────────────────────────────────────────────────────────────────────────┐
│ EXTERNAL USERS │
│ │
│ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│ │ Analyst │ │ Manager │ │ Viewer │ │ Partner │ │
│ └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ │
│ └───────────────┴───────────────┴───────────────┘ │
│ │ │
│ Browser (React App) │
│ localhost:3000 │
└──────────────────────────────────┬──────────────────────────────────────────────┘
│
HTTPS (JWT Token)
│
┌──────────────┴──────────────┐
│ YOUR INFRASTRUCTURE │
│ │
│ ┌────────────────────────┐ │
│ │ FastAPI Proxy │ │
│ │ (localhost:8000) │ │
│ │ │ │
│ │ ┌──────────────────┐ │ │
│ │ │ JWT Auth │ │ │
│ │ │ Middleware │ │ │
│ │ │ │ │ │
│ │ │ • Validate token │ │ │
│ │ │ • Check expiry │ │ │
│ │ │ • Extract user │ │ │
│ │ └───────┬──────────┘ │ │
│ │ │ ✓ Valid │ │
│ │ ┌───────▼──────────┐ │ │
│ │ │ Request Handler │ │ │
│ │ │ │ │ │
│ │ │ • Thread mgmt │ │ │
│ │ │ • Forward to SF │ │ │
│ │ │ • Parse response │ │ │
│ │ └───────┬──────────┘ │ │
│ │ │ │ │
│ │ PAT Token (env var) │ │
│ │ Never exposed │ │
│ └──────────┬─────────────┘ │
│ │ │
└─────────────┼──────────────────┘
│
HTTPS (PAT Auth)
Authorization: Bearer <PAT>
│
┌─────────────────────────────────┴───────────────────────────────────────────────┐
│ SNOWFLAKE ACCOUNT │
│ │
│ ┌───────────────────────────────────────────────────────────────────────────┐ │
│ │ AGENT_SERVICE_USER (TYPE=SERVICE) │ │
│ │ Role: INSIGHT_AGENT_USER │ │
│ │ Network Policy: Locked to proxy IP │ │
│ └───────────────────────────────────┬───────────────────────────────────────┘ │
│ │ │
│ ┌───────────────────────────────────▼───────────────────────────────────────┐ │
│ │ REST API Endpoints │ │
│ │ │ │
│ │ POST /api/v2/cortex/threads → Create conversation thread │ │
│ │ POST /api/v2/databases/INSIGHT_AGENT_DB/ │ │
│ │ schemas/APP/agents/INSIGHT_AGENT:run → Run agent │ │
│ └───────────────────────────────────┬───────────────────────────────────────┘ │
│ │ │
│ ┌───────────────────────────────────▼───────────────────────────────────────┐ │
│ │ │ │
│ │ INSIGHT_AGENT (Agent Object) │ │
│ │ INSIGHT_AGENT_DB.APP │ │
│ │ │ │
│ │ ┌─────────────────────────────────────────────────────────────────────┐ │ │
│ │ │ LLM ORCHESTRATOR │ │ │
│ │ │ Model: auto │ │ │
│ │ │ │ │ │
│ │ │ Instructions: │ │ │
│ │ │ • Data questions → query_sales_data │ │ │
│ │ │ • Definitions → search_business_glossary │ │ │
│ │ │ • Both → glossary first, then analyst │ │ │
│ │ └──────────┬─────────────────────────────────┬────────────────────────┘ │ │
│ │ │ │ │ │
│ │ ┌────────▼──────────┐ ┌────────▼──────────┐ │ │
│ │ │ TOOL 1 │ │ TOOL 2 │ │ │
│ │ │ query_sales_data │ │ search_business │ │ │
│ │ │ │ │ \_glossary │ │ │
│ │ │ Type: │ │ │ │ │
│ │ │ cortex_analyst │ │ Type: │ │ │
│ │ │ \_text_to_sql │ │ cortex_search │ │ │
│ │ └────────┬──────────┘ └────────┬──────────┘ │ │
│ │ │ │ │ │
│ └─────────────┼──────────────────────────────────┼────────────────────────────┘ │
│ │ │ │
│ ┌────────▼──────────┐ ┌────────▼──────────┐ │
│ │ CORTEX ANALYST │ │ CORTEX SEARCH │ │
│ │ │ │ │ │
│ │ Reads: │ │ Service: │ │
│ │ @INSIGHT_AGENT_DB │ │ INSIGHT_AGENT_DB │ │
│ │ .METADATA │ │ .METADATA │ │
│ │ .SEMANTIC_MODELS/ │ │ .GLOSSARY_SEARCH │ │
│ │ tpch_insight │ │ │ │
│ │ \_agent.yaml │ │ Returns: │ │
│ │ │ │ Business term │ │
│ │ 1. Parse question │ │ definitions │ │
│ │ 2. Generate SQL │ └───────────────────┘ │
│ │ 3. Execute SQL │ │
│ └────────┬──────────┘ │
│ │ │
│ ┌────────▼──────────────────────────────────────────────┐ │
│ │ INSIGHT_AGENT_WH │ │
│ │ (Warehouse) │ │
│ │ │ │
│ │ Executes generated SQL against: │ │
│ │ │ │
│ │ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │ │
│ │ │ DIM_CUSTOMER│ │ FACT_ORDERS │ │ DIM_PRODUCT │ │ │
│ │ │ │ │ │ │ │ │ │
│ │ │ • name │ │ • revenue │ │ • name │ │ │
│ │ │ • segment │ │ • quantity │ │ • type │ │ │
│ │ │ • region │ │ • date │ │ • brand │ │ │
│ │ │ • nation │ │ • discount │ │ • size │ │ │
│ │ └─────────────┘ └─────────────┘ └─────────────┘ │ │
│ │ │ │
│ │ Returns: SQL + result_set + explanation │ │
│ └───────────────────────────────────────────────────────┘ │
│ │
└──────────────────────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════════════

DATA FLOW (single request):

User types: "What was total net revenue by region in 1995?"
│
▼
① React → POST /api/chat + JWT
│
▼
② FastAPI validates JWT → extracts user identity
│
▼
③ FastAPI → POST /api/v2/cortex/threads (if new conversation)
│ ← thread_id
▼
④ FastAPI → POST .../agents/INSIGHT_AGENT:run + PAT
│
▼
⑤ Agent orchestrator picks tool: query_sales_data
│
▼
⑥ Cortex Analyst reads semantic YAML → generates SQL
│
▼
⑦ SQL executes on INSIGHT_AGENT_WH → result_set
│
▼
⑧ Agent synthesizes answer text + SQL + results
│
▼
⑨ FastAPI parses response → returns JSON to React
│
▼
⑩ React renders chat bubble + expandable SQL + data table

═══════════════════════════════════════════════════════════════════════════════════

SECURITY BOUNDARIES:

┌─────────────────┐ ┌──────────────────┐ ┌─────────────────┐
│ PUBLIC ZONE │ │ TRUSTED ZONE │ │ SNOWFLAKE ZONE │
│ │ │ │ │ │
│ React App │────▶│ FastAPI Proxy │────▶│ Agent + Data │
│ (browser) │ JWT │ │ PAT │ │
│ │ │ • Auth gateway │ │ • Network │
│ No secrets │ │ • Rate limiting │ │ policy │
│ No SF access │ │ • Audit logging │ │ • Role-based │
│ │ │ • PAT stored │ │ access │
│ │ │ in env var │ │ │
└─────────────────┘ └──────────────────┘ └─────────────────┘
