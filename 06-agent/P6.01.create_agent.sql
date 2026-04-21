USE ROLE INSIGHT_AGENT_ADMIN;
USE WAREHOUSE INSIGHT_AGENT_WH;
USE DATABASE INSIGHT_AGENT_DB;
USE SCHEMA APP;

CREATE OR REPLACE AGENT INSIGHT_AGENT_DB.APP.INSIGHT_AGENT
  WITH PROFILE = '{"display_name": "TPCH Insight Agent"}'
  COMMENT = 'Text-to-SQL + glossary agent over TPCH sample data'
  FROM SPECIFICATION $$
{
  "models": {
    "orchestration": "auto"
  },
  "instructions": {
    "response": "You are a data analyst assistant for a wholesale distribution business. Answer questions using the tools available. When you return data, give a one-sentence summary of what the user is looking at, then show the data. Never make up numbers. If a question is ambiguous, ask for clarification before calling a tool. If a question is definitional (what does X mean), use the glossary search tool. If a question is data (what were the numbers for X), use the analyst tool. If a question needs both — for example, 'what is our revenue and what does revenue mean in our business?' — call both tools and combine the answers.",
    "orchestration": "Prefer the analyst tool for quantitative questions. Prefer the glossary tool for definitional questions. When in doubt about a term's meaning before querying, call glossary first, then analyst. Always explain briefly which tool answered which part of the question.",
    "sample_questions": [
      {"question": "What was total net revenue by region in 1995?"},
      {"question": "Show me the top 10 customers by revenue in 1996"},
      {"question": "What is our on-time delivery rate by shipping mode?"},
      {"question": "What does high-value customer mean in our business?"},
      {"question": "Compare revenue between 1994 and 1995 by region"}
    ]
  },
  "tools": [
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "query_sales_data",
        "description": "Use this tool to answer quantitative questions about revenue, orders, customers, products, shipping, returns, and any numeric business metric. It translates natural language to SQL against the curated data model covering order line items, customers, and products for a wholesale distribution business. Data covers 1992 to 1998."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "search_business_glossary",
        "description": "Use this tool to answer questions about what business terms, metrics, and definitions mean. Examples: 'what does net revenue mean', 'define high-value customer', 'how is on-time delivery calculated'. Do not use this for data lookups — only for definitional and conceptual questions."
      }
    }
  ],
  "tool_resources": {
    "query_sales_data": {
      "semantic_model_file": "@INSIGHT_AGENT_DB.METADATA.SEMANTIC_MODELS/tpch_insight_agent.yaml",
      "execution_environment": {
        "type": "warehouse",
        "warehouse": "INSIGHT_AGENT_WH",
        "query_timeout": 60
      }
    },
    "search_business_glossary": {
      "name": "INSIGHT_AGENT_DB.METADATA.GLOSSARY_SEARCH",
      "max_results": 3,
      "title_column": "term",
      "id_column": "term_id"
    }
  }
}
$$;

SHOW AGENTS IN SCHEMA INSIGHT_AGENT_DB.APP;
DESCRIBE AGENT INSIGHT_AGENT_DB.APP.INSIGHT_AGENT;
