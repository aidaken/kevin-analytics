WITH customer_totals AS (
  SELECT
    CustomerId AS cust_id,
    ROUND(SUM(Total), 2) AS total_spent,
    COUNT(DISTINCT InvoiceId) AS order_count
  FROM Invoice
  GROUP BY 1
),
ranked AS (
  SELECT
    cust_id,
    total_spent,
    order_count,
    NTILE(4) OVER (ORDER BY total_spent DESC) AS spend_quartile
  FROM customer_totals
),
tiered AS (
  SELECT
    cust_id,
    total_spent,
    order_count,
    CASE spend_quartile
      WHEN 1 THEN 'VIP'
      WHEN 2 THEN 'Core'
      WHEN 3 THEN 'Occasional'
      ELSE 'Low'
    END AS value_tier
  FROM ranked
)
SELECT
  value_tier,
  COUNT(*) AS customer_count,
  ROUND(SUM(total_spent), 2) AS revenue_sum,
  ROUND(AVG(total_spent), 2) AS avg_spent
FROM tiered
GROUP BY 1
ORDER BY revenue_sum DESC;

