# Data Dictionary

Column mapping from Bronze (raw CSV columns) to Silver (`silver_sales`). The source file has 33 columns, and Silver keeps all 33.

| Silver column | Bronze column | Silver type | Transformation |
|---------------|---------------|-------------|----------------|
| `order_id` | `OrderID` | STRING | `TRIM` |
| `order_date` | `OrderDate` | DATE | `TRY_CAST` |
| `ship_date` | `ShipDate` | DATE | `TRY_CAST` |
| `ship_mode` | `ShipMode` | STRING | `TRIM` |
| `customer_id` | `CustomerID` | STRING | `TRIM` |
| `customer_name` | `CustomerName` | STRING | `TRIM` |
| `customer_segment` | `CustomerSegment` | STRING | `TRIM` |
| `country` | `Country` | STRING | `TRIM` |
| `region` | `Region` | STRING | `TRIM` |
| `state` | `State` | STRING | `TRIM` |
| `city` | `City` | STRING | `TRIM` |
| `postal_code` | `PostalCode` | INT | `TRY_CAST` |
| `product_id` | `ProductID` | STRING | `TRIM` |
| `product_name` | `ProductName` | STRING | `TRIM` |
| `product_category` | `ProductCategory` | STRING | `TRIM` |
| `product_sub_category` | `ProductSubCategory` | STRING | `TRIM` |
| `brand` | `Brand` | STRING | `TRIM` |
| `supplier` | `Supplier` | STRING | `TRIM` |
| `quantity` | `Quantity` | INT | `TRY_CAST`, must be > 0 |
| `unit_price` | `UnitPrice` | DECIMAL(10,2) | `TRY_CAST` |
| `discount_percent` | `DiscountPercent` | DECIMAL(5,2) | `TRY_CAST` |
| `discount_amount` | `DiscountAmount` | DECIMAL(10,2) | `TRY_CAST` |
| `sales` | `Sales` | DECIMAL(10,2) | `TRY_CAST`, must be > 0 |
| `unit_cost` | `UnitCost` | DECIMAL(10,2) | `TRY_CAST` |
| `total_cost` | `TotalCost` | DECIMAL(10,2) | `TRY_CAST` |
| `profit` | `Profit` | DECIMAL(10,2) | `TRY_CAST`, must not be NULL |
| `payment_method` | `PaymentMethod` | STRING | `TRIM` |
| `sales_channel` | `SalesChannel` | STRING | `TRIM` |
| `sales_rep` | `SalesRep` | STRING | `TRIM` |
| `order_status` | `OrderStatus` | STRING | `TRIM` |
| `returned` | `Returned` | BOOLEAN | `TRY_CAST` |
| `customer_rating` | `CustomerRating` | INT | `TRY_CAST` |
| `currency` | `Currency` | STRING | `TRIM` |

## Bronze audit columns

| Column | Description |
|--------|-------------|
| `source_file` | Path of the file each row was read from (`_metadata.file_path`) |
| `ingested_at` | Timestamp when the row was ingested (`current_timestamp()`) |
