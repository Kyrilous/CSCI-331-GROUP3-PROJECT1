--PROJECT 1
--Used Northwinds2024Student.bak

--Case #001: Sales/Order Fraud
/* One employee has been breaking records too fast and is ranked as the "#1 seller", 
 * as their total number of orders have been sky-rocketing. However, there has been gossip going 
 * around the office, saying that this person has been rigging their sales/orders. 
 * Find out who it is.
 * 
 * Task:
 * 1. Look for employee perfomance (like employeeID, totalQuantity, and totalNumberOfOrders)
 * 2. Find who has highest number of orders
 * 3. Find out the employee’s name who has the highest total number of orders.
 */

--1) so first look at the tables that have these columns: employeeID, totalQuantity, and totalNumberOfOrders
SELECT *
FROM Sales.uvw_EmployeeOrder eo;
--2) Find who has highest number of orders
SELECT EmployeeID, SUM(TotalNumberOfOrders) AS TotalOrders, SUM(TotalQuantity) AS TotalQuantitySold
FROM Sales.uvw_EmployeeOrder
GROUP BY EmployeeID
ORDER BY TotalOrders DESC;
--3) 
SELECT *
FROM HumanResources.Employee e 
WHERE EmployeeID = 4;



--Case #002: The German Connection
/* Agents in Germany intercepted a suspicious package that appears to have come from
 * one of the company’s international shipments. After investigation, they suspect it 
 * originated from the cheapest order sent to Germany.
 * Your mission: track down that order and confirm what was inside.
 *
 * Task:
 * 1. Find the lowest-cost order shipped to Germany.
 * 2. Identify the customer name 
 * 3. Identify the Product Name and it's CategoryID
 */

--1) 
SELECT TOP (3) o.OrderID, od.ProductId, o.CustomerId, od.UnitPrice AS Price, od.Quantity, (od.UnitPrice * od.Quantity) AS TotalCost, o.ShipToCountry
FROM Sales.OrderDetail od 
JOIN Sales.[Order] o
	ON od.OrderID = o.OrderId
WHERE o.ShipToCountry = 'Germany'
ORDER BY TotalCost;

--2) orderID = 10623, productID = 24 Product QOGNU, customerID = 25
SELECT MAX(ucpoaod.OrderId) AS OrderID, MAX(od.ProductId) AS ProductID, 
		MAX(o.CustomerId) AS CustomerID, MAX(ucpoaod.CustomerCompanyName) AS CustomerName
FROM Sales.uvw_CustomerProductOrderAndOrderDetail ucpoaod 
JOIN Sales.[Order] o 
	ON ucpoaod.OrderId = o.OrderId
JOIN Sales.OrderDetail od 
	ON o.OrderID = od.OrderId
WHERE ucpoaod.OrderId = 10623 AND od.ProductId = 24
GROUP BY ucpoaod.CustomerCompanyName;   --Customer AZJED

--3) 
SELECT p.ProductId, p.ProductName, p.CategoryId, p.UnitPrice AS Price
FROM Production.Product p
WHERE p.ProductId = 24; --ProductName Product QOGNU   Category: Bevarages



--Case #003: Partners in Crime
/* In this case, investigators notice something strange, some states have exactly two justices, no more and no less. 
 * That seems unusual. They begin to wonder if these pairs might not be a coincidence. Maybe the two justices from each 
 * of those states were secretly working together. Imagine them as partners in crime — two powerful people who used their 
 * positions to help each other, share secrets, covered for eachother and hide the truth. They could be been planning 
 * something big, like corruption.
 * 
 * Task:
 * 1. Find states with exactly two justices.
 * 2. List their names, ID's and birth years.
 */

--1)
SELECT StateOfBirth, COUNT(*) AS num_justices
FROM RelationalCalculii.USSupremeCourtJustices AS scotus
GROUP BY StateOfBirth
HAVING COUNT(*) = 2;
--Result: Arizona and California have 2 justices

--2)
SELECT *
FROM RelationalCalculii.USSupremeCourtJustices AS scotus
WHERE scotus.StateOfBirth = 'Arizona' OR scotus.StateOfBirth = 'California';



--Case #004: Murder-Case
/* Police found an old man dead in his car. Authorities noticed scattered papers about the Supreme Court and 
 * many old court cases. Investigators now think this man might have been a Supreme Court Justice. The identification 
 * card recovered at the scene lists only a birth year; "1936."
 * 
 * Task:
 * 1. Identify the justice with birth year "1936"
 * 2. Retrieve their full name, birth year, and any state of birth information.
 */

--1)
SELECT *
FROM RelationalCalculii.USSupremeCourtJustices ucj 
WHERE ucj.YearOfBirth = 1936; --two results show up

--2) When Police have went to interview the Justice's one of them mentioned that they did notice a justice was
-- gone. They thought he went back home to California for vacation
SELECT *
FROM RelationalCalculii.USSupremeCourtJustices ucj 
WHERE ucj.YearOfBirth = 1936 AND ucj.StateOfBirth = 'California';



--Case #005: Hidden Evidence
/* Investigators found that several discontinued products may have been used to hide or move evidence. They need a full 
 * list of all items the company no longer sells, including which category they belonged to and who supplied them.
 * 
 * Task:
 * 1. List all discontinued products.
 * 2. List ProductID, ProductName, CategoryName, and SupplierName
 */

--1)
SELECT p.ProductId, p.ProductName, p.CategoryId, p.SupplierId, p.Discontinued
FROM Production.Product AS p
WHERE Discontinued = 1
ORDER BY ProductName;
--2) 
SELECT p.ProductId, p.ProductName, c.CategoryName, s.SupplierCompanyName
FROM Production.Product  AS p
JOIN Production.Category AS c
  ON c.CategoryId = p.CategoryId
JOIN Production.Supplier AS s
	ON p.SupplierId =s.SupplierId
WHERE p.Discontinued = 1
ORDER BY p.ProductName;



--Case #006: Missing Deliveries
/* Several international shipments have disappeared without a trace. The tracking logs show no ShipToDate,
 * meaning that those orders were never confirmed as delivered. Investigators believe that certain countries 
 * might be hotspots for these missing deliveries. To uncover the pattern, the team decides to analyze where 
 * most of the missing shipments were headed.
 * 
 * Task:
 * 1. Find all orders that have no ShipToDate (still missing or stolen).
 * 2. Figure out how many days it has been from Order to Required Date
 * 3. Count how many missing shipments there are per destination country.
*/

--1) orders where there is no SHIP DATE
SELECT o.OrderId, o.OrderDate, o.ShipperId, o.OrderDate, o.RequiredDate, o.ShipToDate, o.ShipToCountry
FROM Sales.[Order] o
WHERE ShipToDate IS NULL;

--2) Delays: how long from OrderDate to RequiredDate per orderID
SELECT o.OrderId, o.OrderDate, o.RequiredDate, o.ShipperId, o.ShipToCountry,
    DATEDIFF(DAY, o.OrderDate, o.RequiredDate) AS Days_Between_Order_and_Required
FROM Sales.[Order] o
WHERE o.ShipToDate IS NULL
ORDER BY Days_Between_Order_and_Required DESC;

--3) per country how many orders in total do they have missing
SELECT ShipToCountry, COUNT(*) AS MissingDeliveries
FROM Sales.[Order]
WHERE ShipToDate IS NULL
GROUP BY ShipToCountry
ORDER BY MissingDeliveries DESC;



--Case #007: Illegal Products
/* A supplier is secretly selling counterfeit pharmaceuticals under harmless-sounding names. 
 * Investigators believe the price of one of these products sold is between the price $40 to $50.
 * They also believe that the Supplier who is doing this is the one with the most sold products
 * 
 * Task:
 * 1) Find products with a price between $40 to $50. 
 * 2) New Evidence has found that the counterfeit products are under the CategoryID: 2
 * 3) Find the supplier company name and number of product sold
 */

--1)
SELECT *
FROM Production.Product p
WHERE p.UnitPrice BETWEEN 40 AND 50
ORDER BY p.UnitPrice DESC;

--2)
SELECT *
FROM Production.Product p
WHERE p.CategoryId = 2
ORDER BY p.UnitPrice DESC;

--3) 
SELECT s.SupplierId, s.SupplierCompanyName, COUNT(p.ProductId) AS NumProducts
FROM Production.Supplier s
JOIN Production.Product p 
    ON s.SupplierId = p.SupplierId
JOIN Production.Category c 
    ON p.CategoryId = c.CategoryId
WHERE c.CategoryId = 2
GROUP BY s.SupplierId, s.SupplierCompanyName, c.CategoryName
ORDER BY NumProducts DESC;
-- result: Supplier VHQZD is selling ounterfeit pharmaceuticals

