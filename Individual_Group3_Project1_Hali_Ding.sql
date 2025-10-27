/* 
 * -- Case #1: Duplicate Invoice
* Some customers were charged twice for the same product on the same day
* Task: Find duplicates by (Customer, Product, OrderDate)
*/

SELECT
	o.CustomerId,
	od.ProductId,
	CAST(o.OrderDate AS date) AS OrderDay,
	COUNT(*) AS LineCount
FROM
	Sales.[Order] AS o
JOIN Sales.OrderDetail AS od ON
	od.OrderId = o.OrderId
GROUP BY
	o.CustomerId,
	od.ProductId,
	CAST(o.OrderDate AS date)
HAVING
	COUNT(*) > 1;

/* 
 * -- Case #2: Shipping Time by Shipper
 * Task: Compute average days from OrderDate to ShipToDate per shipper.
 */

SELECT
	s.ShipperCompanyName,
	AVG(DATEDIFF(DAY, o.OrderDate, o.ShipToDate)) AS AvgDays,
	COUNT(*) AS ShippedOrders
FROM
	Sales.[Order] o
JOIN Sales.Shipper s
  ON
	s.ShipperId = o.ShipperId
WHERE
	o.ShipToDate IS NOT NULL
GROUP BY
	s.ShipperCompanyName
ORDER BY
	AvgDays DESC;


-- Case #3: Overpriced Shipment
/* Some delivery companies are charging too much for shipping.
 *
 * Task: Find the average freight cost for each shipper.
 */
SELECT
	s.ShipperCompanyName,
	AVG(o.Freight) AS AvgFreight
FROM
	Sales.[Order] o
JOIN Sales.Shipper s ON
	s.ShipperId = o.ShipperId
GROUP BY
	s.ShipperCompanyName
ORDER BY
	AvgFreight DESC;


-- Case #4: Produce Catalog
/* Show all products in the "Produce" category.
 *
 * Task: Looks up products that belong to the Category = 'Produce'
 */
SELECT
	DISTINCT
    p.ProductId,
	p.ProductName,
	c.CategoryName
FROM
	Production.Product p
JOIN Production.Category c ON
	c.CategoryId = p.CategoryId
WHERE
	c.CategoryName = 'Produce'
ORDER BY
	p.ProductName;


-- Case #5: Loyalty
/* Some customers order a lot (VIP). Let's find them
 * Task: Find VIP customers (> 20 orders).
 */

SELECT
	CustomerId,
	COUNT(*) AS NumOrders
FROM
	Sales.[Order]
GROUP BY
	CustomerId
HAVING
	COUNT(*) > 20
ORDER BY
	NumOrders DESC;



-- Case #6: Bad Quarter
/* We want to see how many orders each country had in each quarter.
 * Task: Show order counts per country per quarter
 */

SELECT
	o.ShipToCountry,
	DATEPART(YEAR, o.OrderDate) AS Yr,
	DATEPART(QUARTER, o.OrderDate) AS Qtr,
	COUNT(*) AS NumOrders
FROM
	Sales.[Order] AS o
GROUP BY
	o.ShipToCountry,
	DATEPART(YEAR, o.OrderDate),
	DATEPART(QUARTER, o.OrderDate)
ORDER BY
	Yr,
	Qtr,
	o.ShipToCountry;

/* 
 * -- Case #7: Top-Selling Products
 * Task: Identify the top 3 products with the highest total quantity sold.
 */

SELECT TOP 3
    p.ProductId,
	p.ProductName,
	SUM(od.Quantity) AS TotalQty
FROM
	Production.Product AS p
JOIN Sales.OrderDetail AS od
    ON
	od.ProductId = p.ProductId
GROUP BY
	p.ProductId,
	p.ProductName
ORDER BY
	TotalQty DESC;