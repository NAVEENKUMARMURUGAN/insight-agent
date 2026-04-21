USE DATABASE INSIGHT_AGENT_DB;
CREATE OR REPLACE VIEW CURATED.DIM_CUSTOMER
  COMMENT = 'Customers enriched with geography — one row per customer'
AS
SELECT
  c.C_CUSTKEY          AS customer_id,
  c.C_NAME             AS customer_name,
  c.C_ADDRESS          AS customer_address,
  c.C_PHONE            AS customer_phone,
  c.C_ACCTBAL          AS account_balance,
  c.C_MKTSEGMENT       AS market_segment,           -- BUILDING, AUTOMOBILE, MACHINERY, HOUSEHOLD, FURNITURE
  c.C_COMMENT          AS customer_notes,
  n.N_NAME             AS nation,
  r.R_NAME             AS region                    -- AFRICA, AMERICA, ASIA, EUROPE, MIDDLE EAST
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION   n ON c.C_NATIONKEY = n.N_NATIONKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION   r ON n.N_REGIONKEY = r.R_REGIONKEY;

-- Sanity check
SELECT * FROM CURATED.DIM_CUSTOMER LIMIT 5;
SELECT region, COUNT(*) AS customer_count 
FROM CURATED.DIM_CUSTOMER 
GROUP BY region ORDER BY 2 DESC;
