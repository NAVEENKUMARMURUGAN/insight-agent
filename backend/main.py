# backend/main.py
import os
import logging

import httpx
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

load_dotenv()
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

SNOWFLAKE_ACCOUNT_URL = os.environ["SNOWFLAKE_ACCOUNT_URL"]
AGENT_ENDPOINT = f"{SNOWFLAKE_ACCOUNT_URL}/api/v2/databases/INSIGHT_AGENT_DB/schemas/APP/agents/INSIGHT_AGENT:run"
THREAD_ENDPOINT = f"{SNOWFLAKE_ACCOUNT_URL}/api/v2/cortex/threads"
PAT_TOKEN = os.environ["SNOWFLAKE_PAT"]

SF_HEADERS = {
    "Authorization": f"Bearer {PAT_TOKEN}",
    "Content-Type": "application/json",
    "Accept": "application/json",
}


class ChatRequest(BaseModel):
    message: str
    thread_id: int | None = None
    parent_message_id: int | None = None


@app.post("/api/chat")
async def chat(req: ChatRequest):
    async with httpx.AsyncClient(timeout=120) as client:
        thread_id = req.thread_id
        parent_message_id = req.parent_message_id or 0

        if thread_id is None:
            logger.debug("Creating new thread...")
            thread_resp = await client.post(THREAD_ENDPOINT, headers=SF_HEADERS, json={})
            logger.debug(f"Thread response status: {thread_resp.status_code}")
            logger.debug(f"Thread response body: {thread_resp.text}")

            if thread_resp.status_code != 200:
                raise HTTPException(502, f"Thread creation failed: {thread_resp.text}")

            thread_data = thread_resp.json()
            thread_id = thread_data.get("thread_id")
            parent_message_id = 0

            if not thread_id:
                raise HTTPException(502, f"No thread_id in response: {thread_data}")

            logger.debug(f"Created thread_id: {thread_id}")

        body = {
            "thread_id": thread_id,
            "parent_message_id": parent_message_id,
            "stream": False,
            "messages": [
                {"role": "user", "content": [{"type": "text", "text": req.message}]}
            ],
        }

        logger.debug(f"Calling agent: thread_id={thread_id}, parent_message_id={parent_message_id}")
        resp = await client.post(AGENT_ENDPOINT, headers=SF_HEADERS, json=body)
        logger.debug(f"Agent response status: {resp.status_code}")

        if resp.status_code != 200:
            raise HTTPException(502, f"Agent error: {resp.text}")

        data = resp.json()

        answer_text = ""
        generated_sql = None
        result_set = None
        chart_spec = None
        assistant_message_id = None

        for item in data.get("content", []):
            t = item.get("type")

            if t == "text":
                answer_text += item.get("text", "")

            elif t == "tool_result":
                tr = item.get("tool_result", {})
                for c in tr.get("content", []):
                    if c.get("type") == "json":
                        j = c.get("json", {})
                        if j.get("sql"):
                            generated_sql = j["sql"]
                        if j.get("result_set"):
                            result_set = j["result_set"]

            elif t == "table":
                table = item.get("table", {})
                if table.get("result_set"):
                    result_set = table["result_set"]

            elif t == "chart":
                chart = item.get("chart", {})
                if chart.get("chart_spec"):
                    chart_spec = chart["chart_spec"]

        metadata = data.get("metadata", {})
        if isinstance(metadata, dict):
            assistant_message_id = metadata.get("message_id")

        logger.debug(f"Answer: {len(answer_text)} chars, SQL: {bool(generated_sql)}, "
                      f"Results: {bool(result_set)}, assistant_msg_id: {assistant_message_id}")

        return {
            "answer": answer_text,
            "sql": generated_sql,
            "result_set": result_set,
            "chart_spec": chart_spec,
            "thread_id": thread_id,
            "assistant_message_id": assistant_message_id,
        }