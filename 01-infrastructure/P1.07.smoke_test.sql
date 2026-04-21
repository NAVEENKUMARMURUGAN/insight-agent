USE ROLE INSIGHT_AGENT_ADMIN;
USE WAREHOUSE INSIGHT_AGENT_WH;
USE DATABASE INSIGHT_AGENT_DB;

-- Can we see the sample data?
SELECT COUNT(*) AS customer_count 
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;
-- Expect: 150000

-- Can we call a Cortex function? (smoke test for Cortex entitlement)
SELECT SNOWFLAKE.CORTEX.COMPLETE(
  'claude-3-7-sonnet',
  'Respond with the single word: ready'
);
-- Expect: ready

-- Is our stage ready?
LIST @INSIGHT_AGENT_DB.METADATA.SEMANTIC_MODELS;
-- Expect: empty listing (no files yet)
