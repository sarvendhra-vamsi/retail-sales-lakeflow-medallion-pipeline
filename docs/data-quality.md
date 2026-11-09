# Data Quality Rules

All data-quality logic in the pipeline, in one place.

## Summary

| # | Layer | Rule | Mechanism | Effect on rows |
|---|-------|------|-----------|----------------|
| 1 | Bronze | `OrderID IS NOT NULL` (`data_loaded`) | Expectation | Monitored only, rows kept |
| 2 | Silver | `order_id IS NOT NULL` (`valid_order_id`) | Expectation | Monitored (post-filter check) |
| 3 | Silver | `sales > 0` (`valid_sales`) | Expectation | Monitored (post-filter check) |
| 4 | Silver | `quantity > 0` (`valid_quantity`) | Expectation | Monitored (post-filter check) |
| 5 | Silver | `OrderID` not null and not an empty string | `WHERE` filter | Row removed |
| 6 | Silver | `OrderDate` castable to `DATE` | `WHERE` filter | Row removed |
| 7 | Silver | `Sales` castable to `DECIMAL(10,2)` and `> 0` | `WHERE` filter | Row removed |
| 8 | Silver | `Quantity` castable to `INT` and `> 0` | `WHERE` filter | Row removed |
| 9 | Silver | `Profit` castable to `DECIMAL(10,2)` (not NULL) | `WHERE` filter | Row removed |
| 10 | Silver | One row per `OrderID` + `ProductID`, latest `ingested_at` wins | `ROW_NUMBER()` + `QUALIFY` | Duplicates removed |
| 11 | Silver | Leading/trailing spaces removed from text columns | `TRIM()` | Values cleaned |
| 12 | Silver | Type conversion with safe failure | `TRY_CAST()` | Bad values become NULL |

## Expectations vs. filters

- An **expectation** (`CONSTRAINT ... EXPECT`) measures how many rows pass or fail and records the result in the pipeline event log. Without an `ON VIOLATION` clause it does not drop rows.
- A **filter** in the `WHERE` clause is what actually removes rows from Silver.
- Because the Silver filters already exclude invalid rows, the Silver expectations act as post-filter assertions that should report zero violations.

## Data-quality reporting in Gold

| View | Purpose |
|------|---------|
| `gold_data_quality_summary` | Row counts for Bronze and Silver |
| `gold_dq_issues` | Counts raw rows by issue type: missing order ID, duplicate records, zero/negative quantity, negative price or sales |
| `gold_reconciliation` | PASS/FAIL checks across layers |

### Reconciliation checks

| Layer | Check | PASS when |
|-------|-------|-----------|
| Bronze | Raw rows ingested | Always reported as PASS (baseline) |
| Silver | Clean rows do not exceed raw rows | `silver_rows <= bronze_rows` |
| Gold | Gold total orders match Silver | Sum of `order_count` in `gold_monthly_sales_trends` equals the Silver row count |

## Known gaps

- Rejected rows are dropped, not stored. A quarantine table would make rejections auditable.
- Text case is not normalized.
- Business-rule checks such as `ship_date >= order_date` or `profit = sales - total_cost` are not implemented.
