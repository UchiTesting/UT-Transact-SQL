-- ----------------------------------------------------------------------
-- This section goes with the following page
-- https://learn.microsoft.com/en-us/training/modules/use-built-functions-transact-sql/8-exercise-built-in-functions/
--
-- USE BUILT-IN FUNCTIONS AND GROUP BY IN T-SQL
-- ----------------------------------------------------------------------

--------------------------------------
-- Scalar functions
--------------------------------------

-- Scalar function return a single value

-- A simple query
-- YEAR returns a single value
SELECT YEAR(SellStartDate) AS SellStartYear, ProductID, Name
FROM SalesLT.Product
ORDER BY SellStartYear;

-- The different functions return a single value
SELECT YEAR(SellStartDate) AS SellStartYear,
    DATENAME(mm,SellStartDate) AS SellStartMonth,
    DAY(SellStartDate) AS SellStartDay,
    DATENAME(dw, SellStartDate) AS SellStartWeekday,
    DATEDIFF(yy,SellStartDate, GETDATE()) AS YearsSold,
    ProductID,
    Name
FROM SalesLT.Product
ORDER BY SellStartYear;

-- String scalar function CONCAT
SELECT CONCAT(FirstName + ' ', LastName) AS FullName
FROM SalesLT.Customer;

-- Some more string related scalar functions
SELECT UPPER(Name) AS ProductName,
    ProductNumber,
    ROUND(Weight, 0) AS ApproxWeight,
    LEFT(ProductNumber, 2) AS ProductType,
    SUBSTRING(ProductNumber,CHARINDEX('-', ProductNumber) + 1, 4) AS ModelCode,
    SUBSTRING(ProductNumber, LEN(ProductNumber) - CHARINDEX('-', REVERSE(RIGHT(ProductNumber, 3))) + 2, 2) AS SizeCode
FROM SalesLT.Product;


--------------------------------------
-- Use logical functions
--------------------------------------

-- Logical functions are used to apply logical tests to values,
-- and return an appropriate value based on the results of the logical evaluation.

-- Returns only numeric sizes
SELECT Name, Size AS NumericSize
FROM SalesLT.Product
WHERE ISNUMERIC(Size) = 1;

-- Returns a string telling is the size is numeric or not
SELECT Name, IIF(ISNUMERIC(Size) = 1, 'Numeric', 'Non-Numeric') AS SizeType
FROM SalesLT.Product;

--
SELECT prd.Name AS ProductName,
    cat.Name AS Category,
    CHOOSE (cat.ParentProductCategoryID, 'Bikes','Components','Clothing','Accessories') AS ProductType
FROM SalesLT.Product AS prd
JOIN SalesLT.ProductCategory AS cat
    ON prd.ProductCategoryID = cat.ProductCategoryID;


--------------------------------------
-- Use aggregate functions
--------------------------------------

-- Aggregate functions return an aggregated value,
-- such as a sum, count, average, minimum, or maximum.

-- Returns number of products, categories and average price
SELECT COUNT(*) AS Products,
    COUNT(DISTINCT ProductCategoryID) AS Categories,
    AVG(ListPrice) AS AveragePrice
FROM SalesLT.Product;

-- Same as above but filtered on Bikes category
SELECT COUNT(p.ProductID) AS BikeModels, AVG(p.ListPrice) AS AveragePrice
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory AS c
    ON p.ProductCategoryID = c.ProductCategoryID
WHERE c.Name LIKE '%Bikes';

--------------------------------------
-- Group aggregated results with the GROUP BY clause
--------------------------------------

-- Grouping by Salesperson
-- Returns the number of customers by salesperson
SELECT Salesperson, COUNT(CustomerID) AS Customers
FROM SalesLT.Customer
GROUP BY Salesperson
ORDER BY Salesperson;

-- Returns the sale revenue for salesperson with any sale
SELECT c.Salesperson, SUM(oh.SubTotal) AS SalesRevenue
FROM SalesLT.Customer c
JOIN SalesLT.SalesOrderHeader oh
    ON c.CustomerID = oh.CustomerID
GROUP BY c.Salesperson
ORDER BY SalesRevenue DESC;

-- Returns the sale revenue for salesperson with any sale or 0.00
SELECT c.Salesperson, ISNULL(SUM(oh.SubTotal), 0.00) AS SalesRevenue
FROM SalesLT.Customer c
LEFT JOIN SalesLT.SalesOrderHeader oh
    ON c.CustomerID = oh.CustomerID
GROUP BY c.Salesperson
ORDER BY SalesRevenue DESC;

--------------------------------------
-- Filter groups with the HAVING clause
--------------------------------------

-- Causes an error because we use an aggregate function
-- in a WHERE clause.
SELECT Salesperson, COUNT(CustomerID) AS Customers
FROM SalesLT.Customer
WHERE COUNT(CustomerID) > 100
GROUP BY Salesperson
ORDER BY Salesperson;

-- For aggregate functions we use HAVING instead
SELECT Salesperson, COUNT(CustomerID) AS Customers
FROM SalesLT.Customer
GROUP BY Salesperson
HAVING COUNT(CustomerID) > 100
ORDER BY Salesperson;

-------------
-- Challenges
-------------

-----------------------------------------------------
-- Challenge 1: Retrieve order shipping information
-----------------------------------------------------

-- The operations manager wants reports about order shipping based on data in the SalesLT.SalesOrderHeader table.

-- 1. Retrieve the order ID and freight cost of each order.
--      Write a query to return the order ID for each order, together with the the Freight value rounded to two decimal places in a column named FreightCost.
-- 2. Add the shipping method.
--      Extend your query to include a column named ShippingMethod that contains the ShipMethod field, formatted in lower case.
-- 3. Add shipping date details.
--      Extend your query to include columns named ShipYear, ShipMonth, and ShipDay that contain the year, month, and day of the ShipDate. The ShipMonth value should be displayed as the month name (for example, June)

-- SOLUTIONS

-----------------------------------------
-- Challenge 2: Aggregate product sales
-----------------------------------------

-- The sales manager would like reports that include aggregated information about product sales.

-- 1. Retrieve total sales by product
--      Write a query to retrieve a list of the product names from the SalesLT.Product table and the total revenue for each product calculated as the sum of LineTotal from the SalesLT.SalesOrderDetail table, with the results sorted in descending order of total revenue.
-- 2. Filter the product sales list to include only products that cost over 1,000
--      Modify the previous query to include sales totals for products that have a list price of more than 1000.
-- 3. Filter the product sales groups to include only total sales over 20,000
--      Modify the previous query to only include only product groups with a total sales value greater than 20,000.

-- SOLUTIONS

-- SOLUTIONS to move after any exercice have been done

-- 1.1
SELECT SalesOrderID,
    ROUND(Freight, 2) AS FreightCost
FROM SalesLT.SalesOrderHeader;

-- 1.2
SELECT SalesOrderID,
    ROUND(Freight, 2) AS FreightCost,
    LOWER(ShipMethod) AS ShippingMethod
FROM SalesLT.SalesOrderHeader;

-- 1.3
SELECT SalesOrderID,
    ROUND(Freight, 2) AS FreightCost,
    LOWER(ShipMethod) AS ShippingMethod,
    YEAR(ShipDate) AS ShipYear,
    DATENAME(mm, ShipDate) AS ShipMonth,
    DAY(ShipDate) AS ShipDay
FROM SalesLT.SalesOrderHeader;

-- 2.1
SELECT p.Name,SUM(o.LineTotal) AS TotalRevenue
FROM SalesLT.SalesOrderDetail AS o
JOIN SalesLT.Product AS p
    ON o.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalRevenue DESC;

-- 2.2
SELECT p.Name,SUM(o.LineTotal) AS TotalRevenue
FROM SalesLT.SalesOrderDetail AS o
JOIN SalesLT.Product AS p
    ON o.ProductID = p.ProductID
WHERE p.ListPrice > 1000
GROUP BY p.Name
ORDER BY TotalRevenue DESC;

-- 2.3
SELECT p.Name,SUM(o.LineTotal) AS TotalRevenue
FROM SalesLT.SalesOrderDetail AS o
JOIN SalesLT.Product AS p
    ON o.ProductID = p.ProductID
WHERE p.ListPrice > 1000
GROUP BY p.Name
HAVING SUM(o.LineTotal) > 20000
ORDER BY TotalRevenue DESC;
