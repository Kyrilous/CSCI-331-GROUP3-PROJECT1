 /*1.)Managment wants to see which one of their employees has the highest number of sales. They want to see if the number is too large.
 A extreamly large number will raise suspuicion*/
SELECT 
    e.EmployeeFirstName + ' ' + e.EmployeeLastName AS EmployeeName,
    SUM(od.DiscountedLineAmount) AS TotalSales
FROM HumanResources.Employee AS e
JOIN Sales.[Order] AS o ON e.EmployeeID = o.EmployeeID
JOIN Sales.OrderDetail AS od ON o.OrderID = od.OrderID
GROUP BY e.EmployeeFirstName, e.EmployeeLastName
ORDER BY TotalSales DESC;


/*2.) Some discounts were issued without approval. 
Show all customers who’ve received discounts over 20%. */
SELECT 
    c.CustomerContactName,
    e.EmployeeFirstName + ' ' + e.EmployeeLastName AS EmployeeName,
    AVG(od.DiscountPercentage) AS AvgDiscount,
    MAX(od.DiscountPercentage) AS MaxDiscount
FROM Sales.Customer AS c
JOIN Sales.[Order] AS o 
    ON c.CustomerID = o.CustomerID
JOIN Sales.OrderDetail AS od 
    ON o.OrderID = od.OrderID
JOIN HumanResources.Employee AS e
    ON o.EmployeeID = e.EmployeeID
GROUP BY 
    c.CustomerContactName,
    e.EmployeeFirstName,
    e.EmployeeLastName
HAVING MAX(od.DiscountPercentage) > 0.2
ORDER BY MaxDiscount DESC;


/*3.) A few shipments never got their dates logged, are they still sitting in the warehouse? 
Find all orders that have no shipped date.*/
SELECT OrderID, CustomerID, OrderDate, ShipToDate
FROM Sales.[Order]
WHERE ShipToDate IS NULL;


/*4.) Some orders didn’t ship out on time, we must find the delays.
Show orders shipped later than the required date.*/
SELECT OrderID, OrderDate, RequiredDate, ShipToDate
FROM Sales.[Order]
WHERE ShipToDate > RequiredDate;


/*5.) The warehouse is overflowing. The manager swears he didn’t order this much. 
Find products that were ordered in large quantities.(300 units or greater)*/
SELECT 
    p.ProductName,
    e.EmployeeFirstName + ' ' + e.EmployeeLastName AS EmployeeName,
    SUM(od.Quantity) AS TotalQuantity
FROM Production.Product AS p
JOIN Sales.OrderDetail AS od 
    ON p.ProductID = od.ProductID
JOIN Sales.[Order] AS o 
    ON od.OrderID = o.OrderID
JOIN HumanResources.Employee AS e 
    ON o.EmployeeID = e.EmployeeID
GROUP BY 
    p.ProductName,
    e.EmployeeFirstName,
    e.EmployeeLastName
HAVING SUM(od.Quantity) > 300
ORDER BY TotalQuantity DESC;


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*6.) We suspect that an employee has been secretly giving a specific customer unauthorized discounts on their orders.
Find all orders with no discount assigned, but the total amount charged is less than the expected  value */
SELECT 
    o.EmployeeId,
    e.EmployeeFirstName + ' ' + e.EmployeeLastName AS EmployeeName,
    o.OrderDate,
    od.DiscountPercentage,
    od.DiscountedLineAmount,
    SUM(od.Quantity * od.UnitPrice) AS ExpectedTotal
FROM Sales.[Order] AS o
JOIN Sales.OrderDetail AS od
    ON o.OrderId = od.OrderId
JOIN HumanResources.Employee AS e
    ON o.EmployeeId = e.EmployeeId
WHERE (od.DiscountPercentage = 0 OR od.DiscountPercentage IS NULL)
  AND od.DiscountedLineAmount < (od.Quantity * od.UnitPrice)
GROUP BY 
    o.EmployeeId,
    e.EmployeeFirstName,
    e.EmployeeLastName,
    o.OrderDate,
    od.DiscountPercentage,
    od.DiscountedLineAmount;


/*7.) Managment is suspicious that some employees have never processed an order but still get paid for their work days.
Find all employees who have never processed an order.*/ 
SELECT e.EmployeeFirstName + ' ' + e.EmployeeLastName AS EmployeeName
FROM HumanResources.Employee AS e
LEFT JOIN Sales.[Order] AS o ON e.EmployeeID = o.EmployeeID
WHERE o.EmployeeID IS NULL;

