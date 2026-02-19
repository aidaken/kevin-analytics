-- Question: who are our best customers (by spend)?
-- Data: Chinook invoices (Invoice.Total) joined to Customer

SELECT
  c.CustomerId AS cust_id,
  c.FirstName || ' ' || c.LastName AS customer_name,
  ROUND(SUM(i.Total), 2) AS total_spent,
  COUNT(DISTINCT i.InvoiceId) AS order_count
FROM Customer c
JOIN Invoice i
  ON i.CustomerId = c.CustomerId
GROUP BY 1, 2
ORDER BY total_spent DESC
LIMIT 15;

