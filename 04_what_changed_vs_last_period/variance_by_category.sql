DROP VIEW IF EXISTS sales_lines;
DROP VIEW IF EXISTS periods;

CREATE TEMP VIEW sales_lines AS
SELECT * FROM (
  SELECT
    DATE(o.OrderDate) AS order_date,
    c.CategoryName AS category_name,
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
  SELECT p.period, s.*
  FROM sales_lines s
  JOIN periods p ON s.order_date BETWEEN p.start_dt AND p.end_dt
),
agg AS (
  SELECT
    category_name,
    period,
    SUM(quantity) AS units,
    SUM(gross_sales) AS gross_sales,
    SUM(discount_amt) AS discount_amt,
    SUM(net_sales) AS net_sales,
    1.0 * SUM(gross_sales) / NULLIF(SUM(quantity), 0) AS avg_price
  FROM tagged
  GROUP BY 1, 2
),
wide AS (
  SELECT
    a.category_name,

    COALESCE(p.units, 0) AS prior_units,
    COALESCE(c.units, 0) AS current_units,

    COALESCE(p.avg_price, 0) AS prior_avg_price,
    COALESCE(c.avg_price, 0) AS current_avg_price,

    COALESCE(p.gross_sales, 0) AS prior_gross,
    COALESCE(c.gross_sales, 0) AS current_gross,

    COALESCE(p.discount_amt, 0) AS prior_discount,
    COALESCE(c.discount_amt, 0) AS current_discount,

    COALESCE(p.net_sales, 0) AS prior_net,
    COALESCE(c.net_sales, 0) AS current_net
  FROM (SELECT DISTINCT category_name FROM agg) a
  LEFT JOIN agg p ON p.category_name = a.category_name AND p.period = 'prior'
  LEFT JOIN agg c ON c.category_name = a.category_name AND c.period = 'current'
)
SELECT
  category_name,
  ROUND(prior_net, 2) AS prior_net_sales,
  ROUND(current_net, 2) AS current_net_sales,
  ROUND(current_net - prior_net, 2) AS net_change,
  ROUND(1.0 * (current_net - prior_net) / NULLIF(prior_net, 0), 4) AS pct_change,

  ROUND((current_units - prior_units) * prior_avg_price, 2) AS gross_qty_effect,
  ROUND((current_avg_price - prior_avg_price) * current_units, 2) AS gross_price_effect,
  ROUND(-(current_discount - prior_discount), 2) AS discount_effect

FROM wide
ORDER BY net_change DESC;
