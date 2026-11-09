CREATE OR REFRESH STREAMING TABLE bronze_sales
(
  CONSTRAINT data_loaded EXPECT (OrderID IS NOT NULL)
)
COMMENT 'Bronze layer: Raw retail sales data ingested from CSV via Auto Loader'
AS
SELECT
  *,
  _metadata.file_path AS source_file,
  current_timestamp() AS ingested_at
FROM STREAM read_files(
  '/Volumes/retail_sales_sdp/default/sales_volume',
  format => 'csv',
  header => true
);
