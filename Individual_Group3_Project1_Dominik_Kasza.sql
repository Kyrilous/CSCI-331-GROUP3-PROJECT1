Use Northwind
GO

-- The clock is ticking and you need to find out where your package is
-- You see the last truck is constantly delivering late and as it 
--departs from the warehouse, you could makeout the letters "Uni"
SELECT s.CompanyName, COUNT(*) AS LateCount
FROM Orders o
JOIN Shippers s ON o.ShipVia = s.ShipperID
WHERE o.ShippedDate IS NOT NULL
  AND o.ShippedDate > o.RequiredDate
  AND s.CompanyName LIKE '%Uni%'
GROUP BY s.ShipperID, s.CompanyName
ORDER BY LateCount DESC


--A product that used to fly off shelves now sits unsold for months. Who’s the product and what category does it hide in?
SELECT TOP 1 p.ProductID, p.ProductName, c.CategoryName
FROM Products p
LEFT JOIN [Order Details] od ON p.ProductID = od.ProductID
LEFT JOIN Orders o ON od.OrderID = o.OrderID
LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE o.OrderID IS NULL OR o.OrderDate < DATEADD(day, -365, CAST(GETDATE() AS date))
GROUP BY p.ProductID, p.ProductName, c.CategoryName
ORDER BY p.ProductName;

--A shadowy figure keeps returning. Which customer has placed the most orders?
SELECT TOP 1 c.CustomerID, c.CompanyName, c.ContactName, COUNT(o.OrderID) AS OrderCount
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CompanyName, c.ContactName
ORDER BY OrderCount DESC

--Someone placed an order so expensive it made the accountant drop his cigarette. Which single order had the highest total dollar value?
SELECT TOP 1 o.OrderID, o.CustomerID, c.CompanyName,
       SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS OrderTotal
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
LEFT JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY o.OrderID, o.CustomerID, c.CompanyName
ORDER BY OrderTotal DESC

--Two suppliers both claim they shipped the same product — which supplier has sent the most different products to Northwind (the largest supplier catalog)?
SELECT TOP 1 s.SupplierID, s.CompanyName, COUNT(p.ProductID) AS ProductCount
FROM Suppliers s
JOIN Products p ON s.SupplierID = p.SupplierID
GROUP BY s.SupplierID, s.CompanyName
ORDER BY ProductCount DESC

--Someone in the office is taking care of very important orders alone. Which employee processed the highest total sales value (sum of order totals for orders they handled)?
SELECT TOP 1 e.EmployeeID, e.FirstName, e.LastName,
       SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalHandled
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY TotalHandled DESC