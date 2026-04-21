CALL INSIGHT_AGENT_DB.METADATA.TEST_ANALYST_AND_EXECUTE('What was total net revenue by region in 1995?');


SELECT INSIGHT_AGENT_DB.METADATA.ASK_ANALYST('What was total net revenue by region in 1995?'):generated_sql::STRING 
  AS generated_sql;


CALL INSIGHT_AGENT_DB.METADATA.ASK_ANALYST('What was total net revenue by region in 1995?');


CALL INSIGHT_AGENT_DB.METADATA.ASK_ANALYST('Show me late deliveries by shipping mode in the most recent year of data');

SELECT 
  $1:analyst_text::STRING   AS analyst_said,
  $1:generated_sql::STRING  AS generated_sql
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

LIST @INSIGHT_AGENT_DB.METADATA.SEMANTIC_MODELS;


CALL INSIGHT_AGENT_DB.METADATA.ASK_ANALYST('What is the late delivery rate by shipping method in 1995?');

SELECT $1:generated_sql::STRING AS generated_sql
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));
