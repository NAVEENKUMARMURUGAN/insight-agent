USE ROLE INSIGHT_AGENT_ADMIN;
USE DATABASE INSIGHT_AGENT_DB;
USE SCHEMA OBSERVABILITY;

CREATE OR REPLACE TABLE AGENT_FEEDBACK (
  feedback_id           NUMBER AUTOINCREMENT,
  created_at            TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  user_name             VARCHAR(256),
  thread_id             VARCHAR(100),
  message_id            VARCHAR(100),
  user_question         VARCHAR,
  agent_answer          VARCHAR,
  generated_sql         VARCHAR,
  tool_calls            VARIANT,
  rating                VARCHAR(10),         -- 'up' or 'down'
  comment               VARCHAR,
  PRIMARY KEY (feedback_id)
);

GRANT SELECT, INSERT ON TABLE AGENT_FEEDBACK TO ROLE INSIGHT_AGENT_USER;
