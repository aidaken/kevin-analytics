WITH customer_dim AS (
  SELECT CustomerID AS customer_id, Country AS country
  FROM Customers
),
orders_base AS (
  SELECT OrderID AS order_id, CustomerID AS customer_id, DATE(OrderDate) AS order_date
  FROM Orders
),
order_counts AS (
  SELECT customer_id, COUNT(DISTINCT order_id) AS order_count
  FROM orders_base
  GROUP BY 1
),
sales AS (
  SELECT
    o.CustomerID AS customer_id,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS net_sales
  FROM "Order Details" od
  JOIN Orders o ON o.OrderID = od.OrderID
  GROUP BY 1
),
buyers AS (
  SELECT
    c.customer_id,
    COALESCE(oc.order_count, 0) AS order_count,
    COALESCE(s.net_sales, 0) AS net_sales
  FROM customer_dim c
  LEFT JOIN order_counts oc ON oc.customer_id = c.customer_id
  LEFT JOIN sales s ON s.customer_id = c.customer_id
),
vip_cut AS (
  SELECT
    customer_id,
    NTILE(4) OVER (ORDER BY net_sales DESC) AS spend_q
  FROM buyers
  WHERE order_count >= 1
),
flags AS (
  SELECT
    b.customer_id,
    CASE WHEN b.order_count >= 1 THEN 1 ELSE 0 END AS is_buyer,
    CASE WHEN b.order_count >= 2 THEN 1 ELSE 0 END AS is_repeat,
    CASE WHEN b.order_count >= 5 THEN 1 ELSE 0 END AS is_loyal,
    CASE WHEN v.spend_q = 1 THEN 1 ELSE 0 END AS is_vip
  FROM buyers b
  LEFT JOIN vip_cut v ON v.customer_id = b.customer_id
),
steps AS (
  SELECT 'Customers' AS step, COUNT(*) AS users FROM flags
  UNION ALL
  SELECT 'Bought at least once', SUM(is_buyer) FROM flags
  UNION ALL
  SELECT 'Repeat (2+ orders)', SUM(is_repeat) FROM flags
  UNION ALL
  SELECT 'Loyal (5+ orders)', SUM(is_loyal) FROM flags
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
      WHEN 'Loyal (5+ orders)' THEN 4
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
  WHEN 'Loyal (5+ orders)' THEN 4
  ELSE 5
END;
