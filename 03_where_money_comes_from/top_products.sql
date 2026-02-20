WITH sales_lines AS (
  SELECT
    p.ProductName AS product_name,
    c.CategoryName AS category_name,
    (od.UnitPrice * od.Quantity * (1 - od.Discount)) AS net_sales,
    od.Quantity AS quantity
  FROM "Order Details" od
  JOIN Products p ON p.ProductID = od.ProductID
  JOIN Categories c ON c.CategoryID = p.CategoryID
)
SELECT
  product_name,
  category_name,
  SUM(quantity) AS units_sold,
  ROUND(SUM(net_sales), 2) AS net_sales
FROM sales_lines
GROUP BY 1, 2
ORDER BY net_sales DESC
LIMIT 20;
