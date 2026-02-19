WITH invoices AS (
  SELECT
    CustomerId AS cust_id,
    DATE(InvoiceDate) AS invoice_date,
    Total
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
    invoice_date AS comeback_date,
    gap_days
  FROM gaps
  WHERE gap_days >= 180
),
summary AS (
  SELECT
    cust_id,
    COUNT(*) AS comeback_count,
    MAX(gap_days) AS max_gap_days
  FROM reactivations
  GROUP BY 1
)
SELECT
  c.FirstName || ' ' || c.LastName AS customer_name,
  c.Email AS email,
  c.Country AS country,
  COALESCE(s.comeback_count, 0) AS comeback_count,
  COALESCE(s.max_gap_days, 0) AS max_gap_days
FROM Customer c
LEFT JOIN summary s ON s.cust_id = c.CustomerId
ORDER BY comeback_count DESC, max_gap_days DESC, customer_name;

