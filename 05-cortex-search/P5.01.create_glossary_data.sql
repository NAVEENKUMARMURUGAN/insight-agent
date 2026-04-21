USE ROLE INSIGHT_AGENT_ADMIN;
USE WAREHOUSE INSIGHT_AGENT_WH;
USE DATABASE INSIGHT_AGENT_DB;
USE SCHEMA METADATA;

CREATE OR REPLACE TABLE BUSINESS_GLOSSARY (
  term_id        NUMBER AUTOINCREMENT,
  term           VARCHAR(200),
  category       VARCHAR(100),
  definition     VARCHAR(5000),
  example_usage  VARCHAR(2000),
  updated_at     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO BUSINESS_GLOSSARY (term, category, definition, example_usage) VALUES

('Net Revenue',
 'Financial Metric',
 'Line item revenue after discount but before tax. Calculated as gross_revenue × (1 - discount_rate). This is the DEFAULT revenue measure used across all reports. When a business user says "revenue" without qualification, they mean net revenue.',
 'Q: "What was our revenue last year?" → uses net_revenue from fact_order_line_items.'),

('Gross Revenue',
 'Financial Metric',
 'Line item revenue before any discount or tax is applied. Equal to quantity × retail_price. Useful for understanding list-price performance before promotional discounts. Rarely used as a primary metric — prefer net_revenue unless explicitly asked for gross.',
 'Q: "What was the gross sales value before discounts?" → uses gross_revenue.'),

('On-Time Delivery',
 'Operations Metric',
 'A shipment is considered on-time if the receipt_date is on or before the commit_date. The was_delivered_late boolean flag on fact_order_line_items captures the inverse. On-time delivery rate = 1 - (count of late / total shipments).',
 'Q: "What is our on-time delivery rate?" → AVG(CASE WHEN NOT was_delivered_late THEN 1.0 ELSE 0.0 END).'),

('High-Value Customer',
 'Customer Segmentation',
 'A customer whose lifetime net revenue exceeds $500,000 OR who has placed more than 50 orders across the full data range. High-value customers receive priority shipping and dedicated account management. Not to be confused with "VIP customer" which is a formal tier assigned by sales.',
 'Q: "Show me our high-value customers" → filter fact_order_line_items grouped by customer with the two thresholds.'),

('Urgent Order',
 'Order Classification',
 'An order with order_priority = "1-URGENT". These orders are expected to ship within 24 hours of placement and carry a target late-delivery rate below 2%. Urgent orders often command premium shipping costs.',
 'Q: "What is our urgent order volume?" → filter order_priority = ''1-URGENT''.'),

('Market Segment',
 'Customer Segmentation',
 'The industry vertical of the customer. Five values: BUILDING (construction companies), AUTOMOBILE (car manufacturers and dealers), MACHINERY (industrial equipment buyers), HOUSEHOLD (consumer goods distributors), FURNITURE (furniture retailers). Used for segment-level revenue analysis and pricing strategies.',
 'Q: "Which industry buys the most from us?" → GROUP BY market_segment.'),

('Return Flag',
 'Order Lifecycle',
 'The status of a line item after delivery. R = returned by customer, A = accepted (returned and accepted back into stock with no penalty), N = not returned. When computing return rate, count both R and A as returns.',
 'Q: "What is our return rate?" → AVG(CASE WHEN return_flag IN (''R'', ''A'') THEN 1.0 ELSE 0.0 END).'),

('Preferred Supplier',
 'Supply Chain',
 'For each product, the preferred supplier is the one offering the lowest supplier_cost. Flagged as is_preferred_supplier = TRUE in dim_product. Sourcing should default to the preferred supplier unless capacity constraints dictate otherwise.',
 'Q: "Who is the cheapest supplier for part X?" → filter dim_product on product_id with is_preferred_supplier = TRUE.');
