DROP VIEW IF EXISTS sales_lines;
DROP VIEW IF EXISTS periods;

CREATE TEMP VIEW sales_lines AS
SELECT * FROM (
  SELECT
    o.OrderID AS order_id,
    DATE(o.OrderDate) AS order_date,
    o.ShipCountry AS ship_country,
    c.CategoryName AS category_name,
    p.ProductName AS product_name,
    od.UnitPrice AS unit_price,
    od.Quantity AS quantity,
    od.Discount AS discount_rate,
    (od.UnitPrice * od.Quantity) AS gross_sales,
    (od.UnitPrice * od.Quantity * od.Discount) AS discount_amt,
    (od.UnitPrice * od.Quantity * (1 - od.Discount)) AS net_sales
  FROM "Order Details" od
  JOIN Orders o ON o.OrderID = od.OrderID
  JOIN Products p ON p.ProductID = od.ProductID
  JOIN Categories c ON c.CategoryID = p.CategoryID
);

CREATE TEMP VIEW periods AS
WITH bounds AS (
  SELECT DATE(MAX(OrderDate)) AS max_dt
  FROM Orders
)
SELECT 'current' AS period, DATE(max_dt, '-89 days') AS start_dt, max_dt AS end_dt FROM bounds
UNION ALL
SELECT 'prior' AS period, DATE(max_dt, '-179 days') AS start_dt, DATE(max_dt, '-90 days') AS end_dt FROM bounds;

WITH tagged AS (
  SELECT
    p.period,
    s.*
  FROM sales_lines s
  JOIN periods p
    ON s.order_date BETWEEN p.start_dt AND p.end_dt
),
agg AS (
  SELECT
    period,
    SUM(quantity) AS units,
    ROUND(SUM(gross_sales), 2) AS gross_sales,
    ROUND(SUM(discount_amt), 2) AS discount_amt,
    ROUND(SUM(net_sales), 2) AS net_sales
  FROM tagged
  GROUP BY 1
)
SELECT
  (SELECT start_dt FROM periods WHERE period='prior') AS prior_start,
  (SELECT end_dt   FROM periods WHERE period='prior') AS prior_end,
  (SELECT start_dt FROM periods WHERE period='current') AS current_start,
  (SELECT end_dt   FROM periods WHERE period='current') AS current_end,
  (SELECT net_sales FROM agg WHERE period='prior') AS prior_net_sales,
  (SELECT net_sales FROM agg WHERE period='current') AS current_net_sales,
  ROUND((SELECT net_sales FROM agg WHERE period='current') - (SELECT net_sales FROM agg WHERE period='prior'), 2) AS net_sales_change,
  ROUND(
    1.0 * ((SELECT net_sales FROM agg WHERE period='current') - (SELECT net_sales FROM agg WHERE period='prior'))
    / NULLIF((SELECT net_sales FROM agg WHERE period='prior'), 0),
    4
  ) AS pct_change;
