DROP PROCEDURE IF EXISTS INSIGHT_AGENT_DB.APP.ASK_AGENT(STRING);

CREATE OR REPLACE PROCEDURE INSIGHT_AGENT_DB.APP.ASK_AGENT(
    user_message STRING,
    thread_id INT DEFAULT NULL,
    parent_message_id INT DEFAULT NULL
)
RETURNS VARIANT
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

def run(session, user_message, thread_id=None, parent_message_id=None):
    body = {
        "messages": [
            {
                "role": "user",
                "content": [{"type": "text", "text": user_message}]
            }
        ]
    }

    if thread_id is None:
        create_resp = _snowflake.send_snow_api_request(
            "POST",
            "/api/v2/cortex/threads",
            {},
            {},
            {},
            None,
            30000
        )
        create_parsed = _deep_parse(create_resp["content"])
        if isinstance(create_parsed, dict):
            thread_id = create_parsed.get("thread_id") or create_parsed.get("id")
        body["thread_id"] = thread_id
        body["parent_message_id"] = 0
    else:
        body["thread_id"] = thread_id
        body["parent_message_id"] = parent_message_id or 0

    resp = _snowflake.send_snow_api_request(
        "POST",
        "/api/v2/databases/INSIGHT_AGENT_DB/schemas/APP/agents/INSIGHT_AGENT:run",
        {},
        {},
        body,
        None,
        120000
    )

    parsed = _deep_parse(resp["content"])

    text_chunks = []
    thinking_chunks = []
    tool_calls = []
    tool_results = []
    generated_sql = None
    assistant_message_id = None

    if isinstance(parsed, list):
        events = parsed
    elif isinstance(parsed, dict) and "data" in parsed:
        events = parsed["data"]
    else:
        events = [parsed] if parsed else []

    for event in events:
        event = _deep_parse(event) if not isinstance(event, dict) else event
        if not isinstance(event, dict):
            continue

        event_type = event.get("event", "")
        data = _deep_parse(event.get("data", {}))
        if not isinstance(data, dict):
            continue

        if event_type == "metadata":
            meta = data.get("metadata", data)
            if isinstance(meta, dict) and meta.get("role") == "assistant":
                assistant_message_id = meta.get("message_id")

        elif event_type == "response.text.delta":
            text_chunks.append(data.get("text", ""))

        elif event_type == "response.text":
            pass

        elif event_type == "response.thinking.delta":
            thinking_chunks.append(data.get("text", ""))

        elif event_type == "response.tool_result":
            content_list = data.get("content", [])
            if isinstance(content_list, list):
                for rc in content_list:
                    if isinstance(rc, dict) and rc.get("type") == "json":
                        rc_json = rc.get("json", {})
                        if isinstance(rc_json, dict):
                            if rc_json.get("sql"):
                                generated_sql = rc_json["sql"]
                            tool_results.append(rc_json)
            tool_name = data.get("type") or data.get("name", "")
            status = data.get("status", "")
            if tool_name:
                tool_calls.append({"tool": tool_name, "status": status})

        elif event_type == "response.tool_use":
            input_data = data.get("input", {})
            tool_calls.append({"tool": data.get("type") or data.get("name", ""), "input": input_data})

        elif event_type == "response.chart":
            chart_spec = data.get("chart_spec")
            if chart_spec:
                tool_results.append({"type": "chart", "chart_spec": chart_spec})

    return {
        "user_message": user_message,
        "answer_text": "".join(text_chunks),
        "thinking": "".join(thinking_chunks),
        "tool_calls": tool_calls,
        "generated_sql": generated_sql,
        "tool_results": tool_results,
        "thread_id": thread_id,
        "assistant_message_id": assistant_message_id,
        "raw_events": events
    }
$$;


GRANT USAGE ON PROCEDURE INSIGHT_AGENT_DB.APP.ASK_AGENT(STRING, INT, INT) TO ROLE INSIGHT_AGENT_USER;
GRANT USAGE ON AGENT INSIGHT_AGENT_DB.APP.INSIGHT_AGENT TO ROLE INSIGHT_AGENT_USER;

-- Turn 1: Start a new conversation (no thread_id)
CALL INSIGHT_AGENT_DB.APP.ASK_AGENT('What was total net revenue by region in 1995?');

-- Grab thread_id and assistant_message_id for the next turn
SELECT 
  $1:answer_text::STRING           AS answer,
  $1:generated_sql::STRING         AS sql,
  $1:thread_id::INT                AS thread_id,
  $1:assistant_message_id::INT     AS assistant_message_id
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

-- Turn 2: Follow-up using thread_id and assistant_message_id from Turn 1
-- Replace <thread_id> and <assistant_message_id> with actual values from above
-- CALL INSIGHT_AGENT_DB.APP.ASK_AGENT('Now break that down by market segment', <thread_id>, <assistant_message_id>);

CALL INSIGHT_AGENT_DB.APP.ASK_AGENT('What was total net revenue by region in 1995?');

SELECT 
  $1:answer_text::STRING       AS answer,
  $1:thread_id::INT            AS thread_id,
  $1:assistant_message_id::INT AS assistant_message_id
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

55092756

CALL INSIGHT_AGENT_DB.APP.ASK_AGENT(
  'Now break that down by market segment',
  55092756,
  14103742105
);

SELECT 
  $1:answer_text::STRING   AS answer,
  $1:generated_sql::STRING AS sql
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));
