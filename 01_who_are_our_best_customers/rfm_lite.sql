WITH base AS (
  SELECT
    i.CustomerId AS cust_id,
    DATE(MAX(i.InvoiceDate)) AS last_order_date,
    COUNT(DISTINCT i.InvoiceId) AS order_count,
    ROUND(SUM(i.Total), 2) AS total_spent
  FROM Invoice i
  GROUP BY 1
),
global AS (
  SELECT DATE(MAX(InvoiceDate)) AS as_of_date
  FROM Invoice
),
rfm AS (
  SELECT
    b.cust_id,
    b.last_order_date,
    CAST((julianday(g.as_of_date) - julianday(b.last_order_date)) AS INT) AS days_since_last_order,
    b.order_count,
    b.total_spent
  FROM base b
  CROSS JOIN global g
),
scored AS (
  SELECT
    cust_id,
    days_since_last_order,
    order_count,
    total_spent,
    NTILE(4) OVER (ORDER BY days_since_last_order ASC) AS r_q,
    NTILE(4) OVER (ORDER BY order_count DESC) AS f_q,
    NTILE(4) OVER (ORDER BY total_spent DESC) AS m_q
  FROM rfm
),
segmented AS (
  SELECT
    cust_id,
    days_since_last_order,
    order_count,
    total_spent,
    r_q, f_q, m_q,
    CASE
      WHEN r_q = 1 AND m_q = 1 THEN 'VIP_active'
      WHEN r_q = 4 AND m_q = 1 THEN 'VIP_sleepy'
      WHEN r_q = 1 AND m_q IN (2,3) THEN 'Regular_active'
      WHEN r_q = 4 AND m_q IN (2,3,4) THEN 'At_risk'
      ELSE 'Middle'
    END AS segment
  FROM scored
)

SELECT
  segment,
  COUNT(*) AS customer_count,
  ROUND(SUM(total_spent), 2) AS revenue_sum,
  ROUND(AVG(days_since_last_order), 1) AS avg_days_since,
  ROUND(AVG(order_count), 2) AS avg_orders
FROM segmented
GROUP BY 1
ORDER BY revenue_sum DESC;


