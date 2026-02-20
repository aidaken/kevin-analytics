DROP VIEW IF EXISTS cohort_retention;

CREATE TEMP VIEW cohort_retention AS
WITH invoices AS (
  SELECT CustomerId AS cust_id, DATE(InvoiceDate) AS invoice_date
  FROM Invoice
),
customer_months AS (
  SELECT cust_id, DATE(strftime('%Y-%m-01', invoice_date)) AS order_month
  FROM invoices
  GROUP BY 1, 2
),
as_of AS (
  SELECT MAX(order_month) AS as_of_month
  FROM customer_months
),
cohorts AS (
  SELECT cust_id, MIN(order_month) AS cohort_month
  FROM customer_months
  GROUP BY 1
),
activity AS (
  SELECT
    cm.cust_id,
    c.cohort_month,
    cm.order_month,
    (CAST(strftime('%Y', cm.order_month) AS INT) - CAST(strftime('%Y', c.cohort_month) AS INT)) * 12
    + (CAST(strftime('%m', cm.order_month) AS INT) - CAST(strftime('%m', c.cohort_month) AS INT)) AS month_index
  FROM customer_months cm
  JOIN cohorts c ON c.cust_id = cm.cust_id
),
cohort_sizes AS (
  SELECT cohort_month, COUNT(DISTINCT cust_id) AS cohort_size
  FROM cohorts
  GROUP BY 1
),
months AS (
  WITH RECURSIVE m(n) AS (
    SELECT 0
    UNION ALL
    SELECT n + 1 FROM m WHERE n < 24
  )
  SELECT n AS month_index FROM m
),
grid AS (
  SELECT cs.cohort_month, months.month_index
  FROM cohort_sizes cs
  CROSS JOIN months
  CROSS JOIN as_of
  WHERE DATE(cs.cohort_month, printf('+%d months', months.month_index)) <= as_of.as_of_month
),
active_counts AS (
  SELECT cohort_month, month_index, COUNT(DISTINCT cust_id) AS active_customers
  FROM activity
  GROUP BY 1, 2
)
SELECT
  g.cohort_month,
  g.month_index,
  COALESCE(a.active_customers, 0) AS active_customers,
  cs.cohort_size,
  ROUND(1.0 * COALESCE(a.active_customers, 0) / cs.cohort_size, 4) AS retention_rate
FROM grid g
JOIN cohort_sizes cs ON cs.cohort_month = g.cohort_month
LEFT JOIN active_counts a
  ON a.cohort_month = g.cohort_month
 AND a.month_index = g.month_index;

SELECT
  'month_index_range' AS check_name,
  MIN(month_index) AS min_val,
  MAX(month_index) AS max_val
FROM cohort_retention;

SELECT
  'retention_bounds_0_1' AS check_name,
  SUM(CASE WHEN retention_rate < 0 OR retention_rate > 1 THEN 1 ELSE 0 END) AS bad_rows
FROM cohort_retention;

SELECT
  'month0_should_be_1' AS check_name,
  SUM(CASE WHEN month_index = 0 AND active_customers = cohort_size THEN 1 ELSE 0 END) AS ok_rows,
  SUM(CASE WHEN month_index = 0 THEN 1 ELSE 0 END) AS total_rows
FROM cohort_retention;

SELECT
  'active_never_exceeds_cohort' AS check_name,
  SUM(CASE WHEN active_customers > cohort_size THEN 1 ELSE 0 END) AS bad_rows
FROM cohort_retention;
