USE Northwinds2022TSQLV7

--1. CID GOT INFORMATION THAT IMPORTED MEAT/Products are GENETICALLY MODIFIED which causes new unkown virus.And we are helping to find supplier
SELECT PP.ProductId, PP.SupplierId, PP.CategoryId, S.*
FROM Production.Product AS PP
INNER JOIN Production.Supplier AS S ON PP.SupplierId = S.SupplierId
WHERE PP.CategoryId IN ( SELECT CategoryId
    FROM Production.Category
    WHERE CategoryName LIKE '%Meat%'
);

--2. CID what us to find all the customer who brought this meat product
SELECT * 
FROM [Sales].[Order]
WHERE OrderId IN (SELECT OrderId 
                    FROM Sales.OrderDetail
                    WHERE ProductId IN (SELECT ProductId
                                            FROM Production.Product
                                            WHERE CategoryId IN (SELECT CategoryId 
                                                                    FROM Production.Category
                                                                    WHERE CategoryName LIKE '%MEAT%')));

--3. CIA is suspecting that there is unkown drugs is shipped by US reveal using canada as a intermideate way. So we need to find the product come from canada to brand temporary
SELECT P.ProductName, S.*
FROM Production.Supplier AS S
INNER JOIN Production.Product AS P ON (S.SupplierId=P.SupplierId)
WHERE S.SupplierCountry LIKE '%Canada%'


--4. Customer buying supplies coming from canada might be buying unknown drugs. Find a list of those customer
SELECT *
FROM [Sales].[Order] AS S
WHERE S.OrderId IN ( SELECT OrderID
                    FROM Sales.OrderDetail
                    WHERE ProductId IN ( SELECT ProductId
                                            FROM Production.Product
                                            WHERE SupplierId IN (SELECT SupplierId
                                                                    FROM Production.Supplier
                                                                    WHERE SupplierCountry LIKE '%Canada%')))

--5. Employee involed in this transcation
SELECT *
FROM [HumanResources].[Employee]
WHERE EmployeeId IN (SELECT EmployeeId
                    FROM [Sales].[Order]
                    WHERE OrderId IN ( SELECT OrderID
                    FROM Sales.OrderDetail
                    WHERE ProductId IN ( SELECT ProductId
                                            FROM Production.Product
                                            WHERE SupplierId IN (SELECT SupplierId
                                                                    FROM Production.Supplier
                                                                    WHERE SupplierCountry LIKE '%Canada%'))))



--6. Find all order Which is late to customer and possible lost in way or might have to reship
SELECT OrderId, CustomerId, RequiredDate, ShipToDate
FROM [Sales].[Order]
WHERE RequiredDate<ShipToDate


--7. See if there is customer order from same employee unusal time
SELECT EmployeeId, CustomerId, COUNT(*) As NumofOrder
FROM [Sales].[Order]
GROUP BY EmployeeId, CustomerId
ORDER BY NumofOrder desc
