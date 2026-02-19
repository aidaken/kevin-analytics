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
    NTILE(4) OVER (ORDER BY total_spent DESC) AS m_q
  FROM rfm
),
segmented AS (
  SELECT
    cust_id,
    days_since_last_order,
    order_count,
    total_spent,
    CASE
      WHEN r_q = 4 AND m_q = 1 THEN 'VIP_sleepy'
      WHEN r_q = 4 AND m_q IN (2,3,4) THEN 'At_risk'
      ELSE 'Other'
    END AS segment
  FROM scored
)
SELECT
  seg.segment,
  c.FirstName || ' ' || c.LastName AS customer_name,
  c.Email AS email,
  c.Country AS country,
  seg.total_spent,
  seg.order_count,
  seg.days_since_last_order
FROM segmented seg
JOIN Customer c ON c.CustomerId = seg.cust_id
WHERE seg.segment IN ('VIP_sleepy','At_risk')
ORDER BY seg.segment, seg.total_spent DESC;


