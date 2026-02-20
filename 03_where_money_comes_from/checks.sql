DROP VIEW IF EXISTS sales_lines;

CREATE TEMP VIEW sales_lines AS
SELECT
  o.OrderID AS order_id,
  DATE(o.OrderDate) AS order_date,
  o.CustomerID AS customer_id,
  o.ShipCountry AS ship_country,
  od.ProductID AS product_id,
  p.ProductName AS product_name,
  c.CategoryName AS category_name,
  od.UnitPrice AS unit_price,
  od.Quantity AS quantity,
  od.Discount AS discount_rate,
  (od.UnitPrice * od.Quantity) AS gross_sales,
  (od.UnitPrice * od.Quantity * (1 - od.Discount)) AS net_sales
FROM "Order Details" od
JOIN Orders o ON o.OrderID = od.OrderID
JOIN Products p ON p.ProductID = od.ProductID
JOIN Categories c ON c.CategoryID = p.CategoryID;

SELECT
  'row_count_matches_order_details' AS check_name,
  (SELECT COUNT(*) FROM "Order Details") AS order_details_rows,
  (SELECT COUNT(*) FROM sales_lines) AS sales_lines_rows;

SELECT
  'discount_rate_bounds' AS check_name,
  SUM(CASE WHEN discount_rate < 0 OR discount_rate > 1 THEN 1 ELSE 0 END) AS bad_rows
FROM sales_lines;

SELECT
  'no_negative_sales' AS check_name,
  SUM(CASE WHEN gross_sales < 0 OR net_sales < 0 THEN 1 ELSE 0 END) AS bad_rows
FROM sales_lines;

SELECT
  'null_critical_fields' AS check_name,
  SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
  SUM(CASE WHEN ship_country IS NULL THEN 1 ELSE 0 END) AS null_ship_country,
  SUM(CASE WHEN category_name IS NULL THEN 1 ELSE 0 END) AS null_category
FROM sales_lines;

SELECT
  'totals' AS check_name,
  ROUND(SUM(gross_sales), 2) AS gross_total,
  ROUND(SUM(net_sales), 2) AS net_total,
  ROUND(1.0 * SUM(net_sales) / NULLIF(SUM(gross_sales), 0), 4) AS net_over_gross
FROM sales_lines;
