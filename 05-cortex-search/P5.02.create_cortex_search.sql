USE ROLE INSIGHT_AGENT_ADMIN;
USE WAREHOUSE INSIGHT_AGENT_WH;
USE DATABASE INSIGHT_AGENT_DB;
USE SCHEMA METADATA;

-- Drop any stray copy that might have landed in the wrong schema
DROP CORTEX SEARCH SERVICE IF EXISTS INSIGHT_AGENT_DB.PUBLIC.GLOSSARY_SEARCH;
DROP CORTEX SEARCH SERVICE IF EXISTS INSIGHT_AGENT_DB.METADATA.GLOSSARY_SEARCH;

-- Create with fully qualified name
CREATE OR REPLACE CORTEX SEARCH SERVICE INSIGHT_AGENT_DB.METADATA.GLOSSARY_SEARCH
  ON search_text
  ATTRIBUTES term, category, example_usage
  WAREHOUSE = INSIGHT_AGENT_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Hybrid search over the business glossary'
AS
  SELECT
    term_id,
    term,
    category,
    example_usage,
    'Term: ' || term || '\n' ||
    'Category: ' || category || '\n' ||
    'Definition: ' || definition || '\n' ||
    'Example: ' || example_usage  AS search_text
  FROM INSIGHT_AGENT_DB.METADATA.BUSINESS_GLOSSARY;


  SHOW CORTEX SEARCH SERVICES IN SCHEMA INSIGHT_AGENT_DB.METADATA;

  DESCRIBE CORTEX SEARCH SERVICE INSIGHT_AGENT_DB.METADATA.GLOSSARY_SEARCH;

  SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'INSIGHT_AGENT_DB.METADATA.GLOSSARY_SEARCH',
    '{
       "query": "what does revenue mean in our business?",
       "columns": ["term", "category", "example_usage"],
       "limit": 3
     }'
  )
):results AS results;


SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'INSIGHT_AGENT_DB.METADATA.GLOSSARY_SEARCH',
    '{
       "query": "who are our best customers",
       "columns": ["term", "category"],
       "limit": 3
     }'
  )
):results AS results;

SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'INSIGHT_AGENT_DB.METADATA.GLOSSARY_SEARCH',
    '{
       "query": "how do we know if a package arrived on time",
       "columns": ["term", "category"],
       "limit": 3
     }'
  )
):results AS results;
