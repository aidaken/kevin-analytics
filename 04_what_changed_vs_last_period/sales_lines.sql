SELECT
  o.OrderID AS order_id,
  DATE(o.OrderDate) AS order_date,
  o.ShipCountry AS ship_country,

  c.CategoryName AS category_name,
  p.ProductName AS product_name,

  od.UnitPrice AS unit_price,
  od.Quantity AS quantity,
  od.Discount AS discount_rate,

  (od.UnitPrice * od.Quantity) AS gross_sales,
  (od.UnitPrice * od.Quantity * od.Discount) AS discount_amt,
  (od.UnitPrice * od.Quantity * (1 - od.Discount)) AS net_sales
FROM "Order Details" od
JOIN Orders o ON o.OrderID = od.OrderID
JOIN Products p ON p.ProductID = od.ProductID
JOIN Categories c ON c.CategoryID = p.CategoryID;
