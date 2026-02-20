WITH bounds AS (
  SELECT DATE(MAX(OrderDate)) AS max_dt
  FROM Orders
)
SELECT
  'current' AS period,
  DATE(max_dt, '-89 days') AS start_dt,
  max_dt AS end_dt
FROM bounds
UNION ALL
SELECT
  'prior' AS period,
  DATE(max_dt, '-179 days') AS start_dt,
  DATE(max_dt, '-90 days') AS end_dt
FROM bounds;
