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
segments AS (
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
),
invoices AS (
  SELECT
    CustomerId AS cust_id,
    DATE(InvoiceDate) AS invoice_date
  FROM Invoice
),
gaps AS (
  SELECT
    cust_id,
    invoice_date,
    CAST((julianday(invoice_date) - julianday(LAG(invoice_date) OVER (PARTITION BY cust_id ORDER BY invoice_date))) AS INT) AS gap_days
  FROM invoices
),
reactivations AS (
  SELECT
    cust_id,
    COUNT(*) AS comeback_count,
    MAX(gap_days) AS max_gap_days
  FROM gaps
  WHERE gap_days >= 180
  GROUP BY 1
)
SELECT
  s.segment,
  CASE
    WHEN s.segment = 'VIP_sleepy' THEN 'P0'
    WHEN COALESCE(r.comeback_count, 0) > 0 THEN 'P1'
    ELSE 'P2'
  END AS priority,
  c.FirstName || ' ' || c.LastName AS customer_name,
  c.Email AS email,
  c.Country AS country,
  s.total_spent,
  s.order_count,
  s.days_since_last_order,
  COALESCE(r.comeback_count, 0) AS comeback_count,
  COALESCE(r.max_gap_days, 0) AS max_gap_days
FROM segments s
JOIN Customer c ON c.CustomerId = s.cust_id
LEFT JOIN reactivations r ON r.cust_id = s.cust_id
WHERE s.segment IN ('VIP_sleepy','At_risk')
ORDER BY
  priority,
  s.total_spent DESC,
  s.days_since_last_order DESC;
