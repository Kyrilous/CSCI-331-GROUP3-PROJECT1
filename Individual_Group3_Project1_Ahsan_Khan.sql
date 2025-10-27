/* ======================================================
  CASE 1 — THE OVERPRICED FREIGHT
  Detect orders where freight exceeds 20% of the total order value.
====================================================== */
SELECT
 o.OrderID,
 o.OrderDate,
 o.CustomerID,
 ROUND(o.Freight, 2) AS Freight,
 ROUND(SUM(od.LineAmount), 2) AS OrderTotal,
 ROUND(100.0 * o.Freight / NULLIF(SUM(od.LineAmount), 0), 2) AS FreightPercent
FROM Sales.[Order] o
JOIN Sales.OrderDetail od ON o.OrderID = od.OrderID
GROUP BY o.OrderID, o.OrderDate, o.CustomerID, o.Freight
HAVING 100.0 * o.Freight / NULLIF(SUM(od.LineAmount), 0) > 20
ORDER BY FreightPercent DESC;

/* ======================================================
  CASE 2 — THE MISSING SHIPMENT
  Find orders that were charged but never shipped or were delayed.
====================================================== */
-- Orders not shipped but have freight charges or items
SELECT
 o.OrderID,
 o.OrderDate,
 o.ShipToDate,
 o.CustomerID,
 ROUND(o.Freight, 2) AS Freight,
 COALESCE(ROUND(SUM(od.LineAmount), 2), 0) AS OrderTotal
FROM Sales.[Order] o
LEFT JOIN Sales.OrderDetail od ON o.OrderID = od.OrderID
WHERE o.ShipToDate IS NULL
GROUP BY o.OrderID, o.OrderDate, o.ShipToDate, o.CustomerID, o.Freight
ORDER BY o.OrderDate DESC;
-- Orders shipped more than 30 days after order date
SELECT
 o.OrderID,
 o.OrderDate,
 o.ShipToDate,
 DATEDIFF(day, o.OrderDate, o.ShipToDate) AS DaysToShip
FROM Sales.[Order] o
WHERE o.ShipToDate IS NOT NULL
 AND DATEDIFF(day, o.OrderDate, o.ShipToDate) > 30
ORDER BY DaysToShip DESC;

/* ======================================================
  CASE 3 — THE DUPLICATE CUSTOMER
  Identify duplicate customer accounts with the same company name.
====================================================== */
SELECT
 CustomerCompanyName,
 COUNT(CustomerID) AS NumCustomers,
 STRING_AGG(CustomerID, ', ') AS CustomerIDs
FROM Sales.Customer
GROUP BY CustomerCompanyName
HAVING COUNT(CustomerID) > 1
ORDER BY NumCustomers DESC;

/* ======================================================
  CASE 4 — THE HIGH VOLUME PRODUCTS
  Find products with high total sales volume.
  (Note: UnitsInStock not available in this database version)
====================================================== */
SELECT
 p.ProductID,
 p.ProductName,
 COALESCE(SUM(od.Quantity), 0) AS TotalSold,
 COALESCE(ROUND(SUM(od.LineAmount), 2), 0) AS TotalRevenue
FROM Production.Product p
LEFT JOIN Sales.OrderDetail od ON p.ProductID = od.ProductID
GROUP BY p.ProductID, p.ProductName
HAVING COALESCE(SUM(od.Quantity), 0) > 0
ORDER BY TotalSold DESC;

/* ======================================================
  CASE 5 — THE DISCOUNT SCANDAL
  Find order lines where discounts exceed 25% (possible fraud or pricing error).
====================================================== */
SELECT
 od.OrderID,
 od.ProductID,
 p.ProductName,
 od.UnitPrice,
 od.Quantity,
 od.DiscountPercentage,
 ROUND(od.DiscountedLineAmount, 2) AS DiscountedLineAmount,
 ROUND(od.LineAmount, 2) AS LineAmount,
 ROUND(od.LineAmount - od.DiscountedLineAmount, 2) AS DiscountAmount
FROM Sales.OrderDetail od
JOIN Production.Product p ON od.ProductID = p.ProductID
WHERE od.DiscountPercentage > 25
ORDER BY od.DiscountPercentage DESC, od.OrderID;