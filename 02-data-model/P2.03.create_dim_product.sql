USE DATABASE INSIGHT_AGENT_DB;
CREATE OR REPLACE VIEW CURATED.DIM_PRODUCT
  COMMENT = 'Products with supplier details — one row per part-supplier combination'
AS
SELECT
  p.P_PARTKEY                         AS product_id,
  p.P_NAME                            AS product_name,
  p.P_MFGR                            AS manufacturer,
  p.P_BRAND                           AS brand,
  p.P_TYPE                            AS product_type,
  p.P_SIZE                            AS product_size,
  p.P_CONTAINER                       AS container,
  p.P_RETAILPRICE                     AS retail_price,
  s.S_SUPPKEY                         AS supplier_id,
  s.S_NAME                            AS supplier_name,
  ps.PS_SUPPLYCOST                    AS supplier_cost,
  ps.PS_AVAILQTY                      AS quantity_available,
  n.N_NAME                            AS supplier_nation,
  r.R_NAME                            AS supplier_region,
  CASE 
    WHEN ps.PS_SUPPLYCOST = MIN(ps.PS_SUPPLYCOST) OVER (PARTITION BY p.P_PARTKEY)
    THEN TRUE ELSE FALSE
  END                                 AS is_preferred_supplier
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART     p
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PARTSUPP ps ON p.P_PARTKEY    = ps.PS_PARTKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.SUPPLIER s  ON ps.PS_SUPPKEY  = s.S_SUPPKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION   n  ON s.S_NATIONKEY  = n.N_NATIONKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION   r  ON n.N_REGIONKEY  = r.R_REGIONKEY;

-- Sanity check
SELECT * FROM CURATED.DIM_PRODUCT LIMIT 5;
SELECT COUNT(*) FROM CURATED.DIM_PRODUCT;  -- Expect ~800,000
