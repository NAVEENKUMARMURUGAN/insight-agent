SELECT CURRENT_ACCOUNT_NAME() AS account_name,
       CURRENT_REGION() AS region;


SHOW PARAMETERS LIKE 'ENABLE_CORTEX_ANALYST' IN ACCOUNT;

SELECT COUNT(*) FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

USE ROLE ACCOUNTADMIN;

USE ROLE ACCOUNTADMIN;

CREATE DATABASE IF NOT EXISTS INSIGHT_AGENT_DB
  COMMENT = 'Text-to-SQL Insight Agent — Snowflake-native architecture';

USE DATABASE INSIGHT_AGENT_DB;

-- Curated business views (the semantic layer over raw tables)
CREATE SCHEMA IF NOT EXISTS CURATED
  COMMENT = 'Curated business-friendly views over TPCH_SF1';

-- Semantic model YAMLs, glossary docs, verified queries
CREATE SCHEMA IF NOT EXISTS METADATA
  COMMENT = 'Semantic models, glossary, golden queries';

-- Event tables and feedback capture
CREATE SCHEMA IF NOT EXISTS OBSERVABILITY
  COMMENT = 'Agent traces, feedback, eval results';

-- Streamlit app + agent object
CREATE SCHEMA IF NOT EXISTS APP
  COMMENT = 'Streamlit in Snowflake + Cortex Agent objects';
