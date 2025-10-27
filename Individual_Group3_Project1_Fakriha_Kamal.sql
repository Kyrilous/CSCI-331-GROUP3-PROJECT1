--Fakriha's 7 Mystery Queries: 

/* Case #001: Missing Manager
Story: Some employees don’t have a manager listed. HR wants to know who they are.
*/
SELECT e.EmployeeID, e.EmployeeFirstName, e.EmployeeLastName
FROM HumanResources.Employee e
WHERE e.EmployeeManagerId IS NULL;
--result: Sara has no manager listed


/* Case #002: The Duplicate Order
Story : Two customers claim they both received the same order number. 
        Something’s off in ordering records.
*/
SELECT o.OrderID, COUNT(o.CustomerID) AS NumCustomers
FROM Sales.[Order] AS o
GROUP BY o.OrderID
HAVING COUNT(DISTINCT o.CustomerID) > 1;
--result: nothing which means customers claims were wrong


/* Case #003: Ghost Employee
Story: Payroll found an employee with a valid ID, but no recorded department or manager. 
       Could it be a fake profile?
*/
SELECT e.EmployeeID, e.EmployeeFirstName, e.EmployeeLastName, e.HireDate, e.EmployeeTitle
FROM HumanResources.Employee e
LEFT JOIN HumanResources.Employee d
    ON e.EmployeeID = d.EmployeeID   -- LEFT JOIN to find those missing department links
WHERE e.EmployeeManagerId IS NULL;


/* Case #004: The Missing Category
Story: A few products are showing up in orders but have no matching category record. 
       Is someone sneaking in new items?
*/
SELECT DISTINCT p.ProductID, p.ProductName
FROM Production.Product p
LEFT JOIN Production.Category c
    ON p.CategoryID = c.CategoryID   -- LEFT JOIN
LEFT JOIN Sales.OrderDetail od
    ON p.ProductID = od.ProductID
WHERE c.CategoryID IS NULL
  AND od.OrderID IS NOT NULL;


/* Case #005: Employee and Orders
Story: Management wants to see the employees performance.
       They want to know which employees handled which orders.
*/
SELECT e.EmployeeID, e.EmployeeFirstName, e.EmployeeLastName, o.OrderID
FROM HumanResources.Employee e
INNER JOIN Sales.[Order] o
    ON e.EmployeeID = o.EmployeeID;   -- INNER JOIN

    
/* Case #006: Missing Shipment
Story: Some orders were shipped without employee records or customer info.
*/
SELECT o.OrderID, e.EmployeeId, c.CustomerCompanyName
FROM Sales.[Order] o
LEFT JOIN HumanResources.Employee e 
    ON o.EmployeeID = e.EmployeeID
LEFT JOIN Sales.Customer c 
    ON o.CustomerID = c.CustomerID;
--result: every shipment has an orderID and EmployeeID


/* Case #007: Supplier and Product Check
Story: There seems to be suspicious rumors about profuct origin. 
       Check all the products and suppliers.
*/
SELECT s.SupplierCompanyName, p.ProductName
FROM Production.Supplier s
LEFT JOIN Production.Product p
    ON s.SupplierID = p.SupplierID;  -- LEFT JOIN shows all suppliers, even if no products
