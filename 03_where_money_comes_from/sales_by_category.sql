WITH sales_lines AS (
  SELECT
    c.CategoryName AS category_name,
    (od.UnitPrice * od.Quantity * (1 - od.Discount)) AS net_sales,
    od.Quantity AS quantity,
    o.OrderID AS order_id
  FROM "Order Details" od
  JOIN Orders o ON o.OrderID = od.OrderID
  JOIN Products p ON p.ProductID = od.ProductID
  JOIN Categories c ON c.CategoryID = p.CategoryID
)
SELECT
  category_name,
  COUNT(DISTINCT order_id) AS orders_count,
  SUM(quantity) AS units_sold,
  ROUND(SUM(net_sales), 2) AS net_sales,
  ROUND(1.0 * SUM(net_sales) / SUM(SUM(net_sales)) OVER (), 4) AS sales_share
FROM sales_lines
GROUP BY 1
ORDER BY net_sales DESC;
