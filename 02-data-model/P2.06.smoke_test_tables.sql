use database insight_agent_db;
-- Three realistic business questions you should now be able to answer with a single view
-- These are the kinds of questions the agent will generate SQL for

-- Q1: Top 5 customers by revenue in 1995
SELECT customer_name, ROUND(SUM(net_revenue), 0) AS total_revenue
FROM CURATED.FACT_ORDER_LINE_ITEMS
WHERE order_year = 1995
GROUP BY customer_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Q2: On-time delivery rate by shipping mode
SELECT shipping_mode,
       COUNT(*)                                                           AS total_shipments,
       SUM(IFF(was_delivered_late, 1, 0))                                 AS late_shipments,
       ROUND(100.0 * AVG(IFF(was_delivered_late, 1.0, 0.0)), 2)           AS late_pct
FROM CURATED.FACT_ORDER_LINE_ITEMS
WHERE order_year = 1995
GROUP BY shipping_mode
ORDER BY late_pct DESC;

-- Q3: Revenue by region and quarter in 1995
SELECT customer_region, order_quarter, ROUND(SUM(net_revenue), 0) AS revenue
FROM CURATED.FACT_ORDER_LINE_ITEMS
WHERE order_year = 1995
GROUP BY customer_region, order_quarter
ORDER BY customer_region, order_quarter;INSIGHT_AGENT_DB.METADATA.SEMANTIC_MODELS
