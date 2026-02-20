WITH first_purchase AS (
  SELECT
    CustomerId AS cust_id,
    MIN(DATE(InvoiceDate)) AS first_date
  FROM Invoice
  GROUP BY 1
),
repeat_90 AS (
  SELECT
    fp.cust_id,
    CASE
      WHEN EXISTS (
        SELECT 1
        FROM Invoice i
        WHERE i.CustomerId = fp.cust_id
          AND DATE(i.InvoiceDate) > fp.first_date
          AND DATE(i.InvoiceDate) <= DATE(fp.first_date, '+90 days')
      ) THEN 1 ELSE 0
    END AS repeated_in_90d
  FROM first_purchase fp
)
SELECT
  SUM(repeated_in_90d) AS customers_repeated_90d,
  COUNT(*) AS customers_total,
  ROUND(1.0 * SUM(repeated_in_90d) / COUNT(*), 4) AS repeat_rate_90d
FROM repeat_90;
