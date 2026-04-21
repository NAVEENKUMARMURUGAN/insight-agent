USE DATABASE INSIGHT_AGENT_DB;

CREATE OR REPLACE VIEW CURATED.FACT_ORDER_LINE_ITEMS
  COMMENT = 'Order line items enriched with order header and customer — the primary fact view'
AS
SELECT
  -- Order header fields
  o.O_ORDERKEY                         AS order_id,
  o.O_ORDERDATE                        AS order_date,
  o.O_ORDERSTATUS                      AS order_status,           -- F=filled, O=open, P=partial
  o.O_ORDERPRIORITY                    AS order_priority,         -- 1-URGENT, 2-HIGH, 3-MEDIUM, 4-NOT SPECIFIED, 5-LOW
  o.O_TOTALPRICE                       AS order_total_price,
  o.O_CLERK                            AS order_clerk,
  o.O_SHIPPRIORITY                     AS ship_priority,
  
  -- Line item fields
  l.L_LINENUMBER                       AS line_number,
  l.L_PARTKEY                          AS product_id,
  l.L_SUPPKEY                          AS supplier_id,
  l.L_QUANTITY                         AS quantity,
  l.L_EXTENDEDPRICE                    AS gross_revenue,          -- qty × retail_price
  l.L_DISCOUNT                         AS discount_rate,           -- 0.00 to 0.10
  l.L_TAX                              AS tax_rate,
  l.L_EXTENDEDPRICE * (1 - l.L_DISCOUNT) 
                                       AS net_revenue,
  l.L_EXTENDEDPRICE * (1 - l.L_DISCOUNT) * (1 + l.L_TAX)
                                       AS revenue_incl_tax,
  l.L_RETURNFLAG                       AS return_flag,             -- R=returned, N=not returned, A=accepted
  l.L_LINESTATUS                       AS line_status,
  l.L_SHIPDATE                         AS ship_date,
  l.L_COMMITDATE                       AS commit_date,
  l.L_RECEIPTDATE                      AS receipt_date,
  l.L_SHIPINSTRUCT                     AS shipping_instructions,
  l.L_SHIPMODE                         AS shipping_mode,           -- AIR, MAIL, RAIL, REG AIR, SHIP, TRUCK, FOB
  
  -- Customer enrichment
  c.customer_id                        AS customer_id,
  c.customer_name                      AS customer_name,
  c.market_segment                     AS market_segment,
  c.nation                             AS customer_nation,
  c.region                             AS customer_region,
  
  -- Derived time dimensions (gives Cortex Analyst easy handles)
  YEAR(o.O_ORDERDATE)                  AS order_year,
  QUARTER(o.O_ORDERDATE)               AS order_quarter,
  MONTH(o.O_ORDERDATE)                 AS order_month,
  DATE_TRUNC('MONTH', o.O_ORDERDATE)   AS order_month_start,
  
  -- Lifecycle flags (business-useful booleans)
  CASE WHEN l.L_RECEIPTDATE > l.L_COMMITDATE THEN TRUE ELSE FALSE END AS was_delivered_late,
  DATEDIFF('day', l.L_SHIPDATE, l.L_RECEIPTDATE) AS days_in_transit
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS    o
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM  l ON o.O_ORDERKEY  = l.L_ORDERKEY
JOIN CURATED.DIM_CUSTOMER                      c ON o.O_CUSTKEY   = c.customer_id;

-- Sanity checks — these should all work and return reasonable numbers
SELECT COUNT(*) FROM CURATED.FACT_ORDER_LINE_ITEMS;  -- Expect ~6,001,215

SELECT order_year, ROUND(SUM(net_revenue), 0) AS annual_revenue
FROM CURATED.FACT_ORDER_LINE_ITEMS
GROUP BY order_year 
ORDER BY order_year;
-- Expect data roughly 1992–1998, revenue hundreds of millions per year

SELECT customer_region, COUNT(DISTINCT order_id) AS order_count
FROM CURATED.FACT_ORDER_LINE_ITEMS
WHERE order_year = 1995
GROUP BY customer_region
ORDER BY 2 DESC;
