-- Admin: manages the agent, semantic models, everything
CREATE ROLE IF NOT EXISTS INSIGHT_AGENT_ADMIN
  COMMENT = 'Full control over agent estate';

-- Dev: can modify semantic models, test, deploy
CREATE ROLE IF NOT EXISTS INSIGHT_AGENT_DEV
  COMMENT = 'Builds and tests the agent';

-- User: end users who chat with the agent
CREATE ROLE IF NOT EXISTS INSIGHT_AGENT_USER
  COMMENT = 'End users asking questions';

-- Role hierarchy: SYSADMIN > ADMIN > DEV > USER
GRANT ROLE INSIGHT_AGENT_USER  TO ROLE INSIGHT_AGENT_DEV;
GRANT ROLE INSIGHT_AGENT_DEV   TO ROLE INSIGHT_AGENT_ADMIN;
GRANT ROLE INSIGHT_AGENT_ADMIN TO ROLE SYSADMIN;
