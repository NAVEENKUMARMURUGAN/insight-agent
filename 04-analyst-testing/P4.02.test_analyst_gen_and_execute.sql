CREATE OR REPLACE PROCEDURE INSIGHT_AGENT_DB.METADATA.TEST_ANALYST_AND_EXECUTE(QUESTION STRING)
RETURNS TABLE()
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'run'
AS
$$
import _snowflake
import json

def _deep_parse(raw):
    parsed = raw
    while isinstance(parsed, str):
        try:
            parsed = json.loads(parsed)
        except (json.JSONDecodeError, TypeError):
            break
    return parsed

def run(session, question):
    body = {
        "messages": [{"role": "user", "content": [{"type": "text", "text": question}]}],
        "semantic_model_file": 
            "@INSIGHT_AGENT_DB.METADATA.SEMANTIC_MODELS/tpch_insight_agent.yaml"
    }
    resp = _snowflake.send_snow_api_request(
        "POST", "/api/v2/cortex/analyst/message", {}, {}, body, None, 60000
    )
    parsed = _deep_parse(resp["content"])
    
    sql = None
    if isinstance(parsed, dict):
        msg = _deep_parse(parsed.get("message", {}))
        if isinstance(msg, dict):
            for block in msg.get("content", []):
                if block.get("type") == "sql":
                    sql = block.get("statement")
                    break
    
    if not sql:
        return session.create_dataframe([("No SQL generated",)], schema=["error"])
    
    return session.sql(sql)
$$;
