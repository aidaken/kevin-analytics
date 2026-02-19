-- Data checks for bestt customers

-- Step 1: We need to makeit so the invoice count should not change after join, so
SELECT
  (SELECT COUNT(*) FROM Invoice) AS invoice_cnt,
  (SELECT COUNT(*) FROM Invoice i JOIN Customer c ON c.CustomerId = i.CustomerId) AS joined_invoice_cnt;

-- Step 2: CustomerId uniqueness
SELECT
  COUNT(*) AS customer_rows,
  COUNT(DISTINCT CustomerId) AS distinct_customer_ids
FROM Customer;

-- Step 3: Negative totals
SELECT COUNT(*) AS negative_total_cnt
FROM Invoice
WHERE Total < 0;

-- Step 4: Null keys
SELECT
  SUM(CASE WHEN CustomerId IS NULL THEN 1 ELSE 0 END) AS null_customer_id_cnt
FROM Customer;

SELECT
  SUM(CASE WHEN CustomerId IS NULL THEN 1 ELSE 0 END) AS null_invoice_customer_id_cnt
FROM Invoice;

-- Step 5: Totals reconcile
WITH customer_totals AS (
  SELECT
    CustomerId,
    SUM(Total) AS total_spent
  FROM Invoice
  GROUP BY 1
)
SELECT
  ROUND((SELECT SUM(Total) FROM Invoice), 2) AS invoice_total_sum,
  ROUND((SELECT SUM(total_spent) FROM customer_totals), 2) AS customer_total_sum;
