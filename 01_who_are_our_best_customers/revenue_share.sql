WITH customer_totals AS (
  SELECT
    CustomerId AS cust_id,
    SUM(Total) AS total_spent
  FROM Invoice
  GROUP BY 1
),
ranked AS (
  SELECT
    cust_id,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent DESC) AS q
  FROM customer_totals
),
tiered AS (
  SELECT
    CASE q
      WHEN 1 THEN 'VIP'
      WHEN 2 THEN 'Core'
      WHEN 3 THEN 'Occasional'
      ELSE 'Low'
    END AS value_tier,
    total_spent
  FROM ranked
),
totals AS (
  SELECT SUM(total_spent) AS total_revenue FROM tiered
)
SELECT
  value_tier,
  ROUND(SUM(total_spent), 2) AS revenue_sum,
  ROUND(100.0 * SUM(total_spent) / (SELECT total_revenue FROM totals), 1) AS revenue_pct
FROM tiered
GROUP BY 1
ORDER BY revenue_sum DESC;


