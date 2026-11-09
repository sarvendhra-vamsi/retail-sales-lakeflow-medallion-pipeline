-- ============================================================
-- VALIDATION QUERIES
-- Run these in Databricks SQL after the pipeline refreshes successfully.
-- ============================================================

-- 1. Row counts per layer
SELECT COUNT(*) AS bronze_count FROM bronze_sales;
SELECT COUNT(*) AS silver_count FROM silver_sales;

-- 2. Data quality summary (Bronze vs Silver)
SELECT * FROM gold_data_quality_summary;

-- 3. Data quality issues found in the raw data
SELECT * FROM gold_dq_issues ORDER BY row_count DESC;

-- 4. Reconciliation: every layer should show PASS
SELECT * FROM gold_reconciliation;

-- 5. Monthly sales trends
SELECT * FROM gold_monthly_sales_trends
ORDER BY order_year, order_month;

-- 6. Product performance
SELECT * FROM gold_product_performance
ORDER BY total_sales DESC;

-- 7. Category performance
SELECT * FROM gold_sales_by_category
ORDER BY total_sales DESC;

-- 8. Regional performance
SELECT * FROM gold_sales_by_region
ORDER BY total_sales DESC;

-- 9. Customer segment performance
SELECT * FROM gold_segment_performance
ORDER BY total_sales DESC;

-- 10. Sales channel performance
SELECT * FROM gold_channel_performance
ORDER BY total_sales DESC;

-- 11. Top 20 products by sales rank
--     (the view ranks all products; the limit is applied when reading)
SELECT * FROM gold_top_products
ORDER BY sales_rank, product_id
LIMIT 20;
