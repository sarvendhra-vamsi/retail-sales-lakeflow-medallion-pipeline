CREATE OR REFRESH MATERIALIZED VIEW silver_sales
(
  CONSTRAINT valid_order_id EXPECT (order_id IS NOT NULL),
  CONSTRAINT valid_sales EXPECT (sales > 0),
  CONSTRAINT valid_quantity EXPECT (quantity > 0)
)
COMMENT 'Silver layer: Cleaned and validated retail sales data'
AS
SELECT
  TRIM(OrderID) AS order_id,
  TRY_CAST(OrderDate AS DATE) AS order_date,
  TRY_CAST(ShipDate AS DATE) AS ship_date,
  TRIM(ShipMode) AS ship_mode,
  TRIM(CustomerID) AS customer_id,
  TRIM(CustomerName) AS customer_name,
  TRIM(CustomerSegment) AS customer_segment,
  TRIM(Country) AS country,
  TRIM(Region) AS region,
  TRIM(State) AS state,
  TRIM(City) AS city,
  TRY_CAST(PostalCode AS INT) AS postal_code,
  TRIM(ProductID) AS product_id,
  TRIM(ProductName) AS product_name,
  TRIM(ProductCategory) AS product_category,
  TRIM(ProductSubCategory) AS product_sub_category,
  TRIM(Brand) AS brand,
  TRIM(Supplier) AS supplier,
  TRY_CAST(Quantity AS INT) AS quantity,
  TRY_CAST(UnitPrice AS DECIMAL(10,2)) AS unit_price,
  TRY_CAST(DiscountPercent AS DECIMAL(5,2)) AS discount_percent,
  TRY_CAST(DiscountAmount AS DECIMAL(10,2)) AS discount_amount,
  TRY_CAST(Sales AS DECIMAL(10,2)) AS sales,
  TRY_CAST(UnitCost AS DECIMAL(10,2)) AS unit_cost,
  TRY_CAST(TotalCost AS DECIMAL(10,2)) AS total_cost,
  TRY_CAST(Profit AS DECIMAL(10,2)) AS profit,
  TRIM(PaymentMethod) AS payment_method,
  TRIM(SalesChannel) AS sales_channel,
  TRIM(SalesRep) AS sales_rep,
  TRIM(OrderStatus) AS order_status,
  TRY_CAST(Returned AS BOOLEAN) AS returned,
  TRY_CAST(CustomerRating AS INT) AS customer_rating,
  TRIM(Currency) AS currency
FROM bronze_sales

WHERE TRIM(OrderID) IS NOT NULL
  AND TRIM(OrderID) != ''
  AND TRY_CAST(OrderDate AS DATE) IS NOT NULL
  AND TRY_CAST(Sales AS DECIMAL(10,2)) > 0
  AND TRY_CAST(Quantity AS INT) > 0
  AND TRY_CAST(Profit AS DECIMAL(10,2)) IS NOT NULL

QUALIFY ROW_NUMBER() OVER (
  PARTITION BY TRIM(OrderID), TRIM(ProductID)
  ORDER BY ingested_at DESC
) = 1;
