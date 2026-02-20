WITH customers AS (
  SELECT CustomerId AS cust_id, Country AS country
  FROM Customer
),
orders AS (
  SELECT CustomerId AS cust_id, InvoiceId AS invoice_id, DATE(InvoiceDate) AS invoice_date, Total
  FROM Invoice
),
order_counts AS (
  SELECT
    cust_id,
    COUNT(DISTINCT invoice_id) AS order_count,
    ROUND(SUM(Total), 2) AS total_spent
  FROM orders
  GROUP BY 1
),
spend_quartile AS (
  SELECT
    cust_id,
    NTILE(4) OVER (ORDER BY total_spent DESC) AS spend_q
  FROM order_counts
),
flags AS (
  SELECT
    c.cust_id,
    c.country,
    CASE WHEN oc.order_count >= 1 THEN 1 ELSE 0 END AS is_buyer,
    CASE WHEN oc.order_count >= 2 THEN 1 ELSE 0 END AS is_repeat,
    CASE WHEN oc.order_count >= 3 THEN 1 ELSE 0 END AS is_loyal,
    CASE WHEN sq.spend_q = 1 THEN 1 ELSE 0 END AS is_vip
  FROM customers c
  LEFT JOIN order_counts oc ON oc.cust_id = c.cust_id
  LEFT JOIN spend_quartile sq ON sq.cust_id = c.cust_id
),
steps AS (
  SELECT 'Customers' AS step, COUNT(*) AS users FROM flags
  UNION ALL
  SELECT 'Bought at least once', SUM(is_buyer) FROM flags
  UNION ALL
  SELECT 'Repeat (2+ orders)', SUM(is_repeat) FROM flags
  UNION ALL
  SELECT 'Loyal (3+ orders)', SUM(is_loyal) FROM flags
  UNION ALL
  SELECT 'VIP (top quartile spend)', SUM(is_vip) FROM flags
),
with_rates AS (
  SELECT
    step,
    users,
    LAG(users) OVER (ORDER BY CASE step
      WHEN 'Customers' THEN 1
      WHEN 'Bought at least once' THEN 2
      WHEN 'Repeat (2+ orders)' THEN 3
      WHEN 'Loyal (3+ orders)' THEN 4
      ELSE 5
    END) AS prev_users
  FROM steps
)
SELECT
  step,
  users,
  CASE WHEN prev_users IS NULL THEN NULL ELSE ROUND(1.0 * users / prev_users, 4) END AS step_rate
FROM with_rates
ORDER BY CASE step
  WHEN 'Customers' THEN 1
  WHEN 'Bought at least once' THEN 2
  WHEN 'Repeat (2+ orders)' THEN 3
  WHEN 'Loyal (3+ orders)' THEN 4
  ELSE 5
END;
