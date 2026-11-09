CREATE OR REFRESH MATERIALIZED VIEW gold_data_quality_summary
COMMENT 'Data quality summary: row counts across pipeline layers'
AS

SELECT
  'Bronze (raw)' AS layer,
  'Raw records from CSV' AS description,
  COUNT(*) AS row_count
FROM bronze_sales

UNION ALL

SELECT
  'Silver (clean)' AS layer,
  'Valid, deduplicated records' AS description,
  COUNT(*) AS row_count
FROM silver_sales;

CREATE OR REFRESH MATERIALIZED VIEW gold_monthly_sales_trends
COMMENT 'Gold layer: Monthly sales and profit trends over time'
AS
SELECT
  YEAR(order_date) AS order_year,
  MONTH(order_date) AS order_month,
  COUNT(*) AS order_count,
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  AVG(sales) AS avg_sales,
  SUM(quantity) AS total_quantity
FROM silver_sales
GROUP BY ALL;

CREATE OR REFRESH MATERIALIZED VIEW gold_product_performance
COMMENT 'Gold layer: per-product sales, profit, and rating performance'
AS
SELECT
  product_id,
  product_name,
  product_category,
  product_sub_category,
  COUNT(*) AS order_count,
  SUM(quantity) AS total_quantity_sold,
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  AVG(sales) AS avg_sales_per_order,
  AVG(customer_rating) AS avg_customer_rating,
  CASE WHEN SUM(sales) = 0 THEN 0 ELSE SUM(profit) / SUM(sales) * 100 END AS profit_margin_percent
FROM silver_sales
GROUP BY ALL;

CREATE OR REFRESH MATERIALIZED VIEW gold_sales_by_category
COMMENT 'Gold layer: sales and profit aggregated by product category and sub-category'
AS
SELECT
  product_category,
  product_sub_category,
  COUNT(*) AS order_count,
  SUM(quantity) AS total_quantity,
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  AVG(sales) AS avg_sales,
  AVG(profit) AS avg_profit,
  CASE WHEN SUM(sales) = 0 THEN 0 ELSE SUM(profit) / SUM(sales) * 100 END AS profit_margin_percent
FROM silver_sales
GROUP BY ALL;

CREATE OR REFRESH MATERIALIZED VIEW gold_sales_by_region
COMMENT 'Gold layer: sales and profit aggregated by region and state'
AS
SELECT
  region,
  state,
  COUNT(*) AS order_count,
  COUNT(DISTINCT customer_id) AS unique_customers,
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  AVG(sales) AS avg_sales,
  CASE WHEN SUM(sales) = 0 THEN 0 ELSE SUM(profit) / SUM(sales) * 100 END AS profit_margin_percent
FROM silver_sales
GROUP BY ALL;

CREATE OR REFRESH MATERIALIZED VIEW gold_top_products
COMMENT 'Gold layer: all products ranked by total sales and total profit'
AS
WITH product_totals AS (
  SELECT
    product_id,
    product_name,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    SUM(quantity) AS total_quantity_sold,
    COUNT(*) AS order_count
  FROM silver_sales
  GROUP BY ALL
)
SELECT
  product_id,
  product_name,
  total_sales,
  total_profit,
  total_quantity_sold,
  order_count,
  RANK() OVER (ORDER BY total_sales DESC) AS sales_rank,
  RANK() OVER (ORDER BY total_profit DESC) AS profit_rank
FROM product_totals;

CREATE OR REFRESH MATERIALIZED VIEW gold_segment_performance
COMMENT 'Gold layer: sales and profit by customer segment'
AS
SELECT
  customer_segment,
  COUNT(*) AS order_count,
  SUM(quantity) AS total_quantity,
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  AVG(sales) AS avg_sales,
  CASE WHEN SUM(sales) = 0 THEN 0 ELSE SUM(profit) / SUM(sales) * 100 END AS profit_margin_percent
FROM silver_sales
GROUP BY ALL;

CREATE OR REFRESH MATERIALIZED VIEW gold_channel_performance
COMMENT 'Gold layer: sales and profit by sales channel'
AS
SELECT
  sales_channel,
  COUNT(*) AS order_count,
  SUM(quantity) AS total_quantity,
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  AVG(sales) AS avg_sales,
  CASE WHEN SUM(sales) = 0 THEN 0 ELSE SUM(profit) / SUM(sales) * 100 END AS profit_margin_percent
FROM silver_sales
GROUP BY ALL;

CREATE OR REFRESH MATERIALIZED VIEW gold_dq_issues
COMMENT 'Gold layer: data quality issues found in the raw bronze data, by type'
AS
SELECT
  'Missing order ID' AS issue_type,
  COUNT(*) AS row_count
FROM bronze_sales
WHERE OrderID IS NULL OR TRIM(OrderID) = ''

UNION ALL

SELECT
  'Duplicate records',
  COUNT(*) - COUNT(DISTINCT CONCAT(TRIM(OrderID), '|', TRIM(ProductID)))
FROM bronze_sales

UNION ALL

SELECT
  'Zero or negative quantity',
  COUNT(*)
FROM bronze_sales
WHERE Quantity IS NULL OR Quantity <= 0

UNION ALL

SELECT
  'Negative price or sales',
  COUNT(*)
FROM bronze_sales
WHERE Sales < 0 OR UnitPrice < 0;

CREATE OR REFRESH MATERIALIZED VIEW gold_reconciliation
COMMENT 'Gold layer: row-count reconciliation across layers with PASS/FAIL status'
AS
WITH bronze AS (
  SELECT COUNT(*) AS n FROM bronze_sales
),
silver AS (
  SELECT COUNT(*) AS n FROM silver_sales
),
gold_orders AS (
  SELECT COALESCE(SUM(order_count), 0) AS n FROM gold_monthly_sales_trends
)
SELECT
  'Bronze' AS layer,
  bronze.n AS row_count,
  'Raw rows ingested from source files' AS description,
  'PASS' AS status
FROM bronze

UNION ALL

SELECT
  'Silver',
  silver.n,
  'Clean rows do not exceed raw rows',
  CASE WHEN silver.n <= bronze.n THEN 'PASS' ELSE 'FAIL' END
FROM silver CROSS JOIN bronze

UNION ALL

SELECT
  'Gold',
  gold_orders.n,
  'Gold total orders match Silver row count',
  CASE WHEN gold_orders.n = silver.n THEN 'PASS' ELSE 'FAIL' END
FROM gold_orders CROSS JOIN silver;

