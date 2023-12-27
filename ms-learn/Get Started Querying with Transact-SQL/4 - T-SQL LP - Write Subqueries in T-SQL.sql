-- ----------------------------------------------------------------------
-- This section goes with the following page
-- https://learn.microsoft.com/en-us/training/modules/write-subqueries/5-exercise-subqueries/
--
-- WRITE SUBQUERIES IN T-SQL
-- ----------------------------------------------------------------------

--------------------------------------
-- Chapter Use simple subqueries
--------------------------------------

-- A subquery is a query that is nested within another query.
-- The subquery is often referred to as the inner query,
-- and the query within which it is nested is referred to as the outer query.

-- A simple query
-- It has a single result
SELECT MAX(UnitPrice)
FROM SalesLT.SalesOrderDetail;

-- Previous query used as subquery
SELECT Name, ListPrice
FROM SalesLT.Product
WHERE ListPrice >
    (SELECT MAX(UnitPrice)
    FROM SalesLT.SalesOrderDetail);

-- Another simple query
-- It has more than 1 result (2 actually)
SELECT DISTINCT ProductID
FROM SalesLT.SalesOrderDetail
WHERE OrderQty >= 20;

-- Name of the products with 20+ orders
SELECT Name FROM SalesLT.Product
WHERE ProductID IN
    (SELECT DISTINCT ProductID
    FROM SalesLT.SalesOrderDetail
    WHERE OrderQty >= 20);

-- Same with a JOIN
SELECT DISTINCT Name
FROM SalesLT.Product AS p
JOIN SalesLT.SalesOrderDetail AS o
    ON p.ProductID = o.ProductID
WHERE OrderQty >= 20;

-- Often you can achieve the same outcome with a subquery or a join,
-- and often a subquery approach can be more easily interpreted by a developer looking at the code than a complex join query
-- because the operation can be broken down into discrete components.
-- In most cases, the performance of equivalent join or subquery operations is similar,
-- but in some cases where existence checks need to be performed, joins perform better.

--------------------------------------
-- Chapter Use correlated subqueries
--------------------------------------

-- So far, the subqueries we’ve used have been independent of the outer query.
-- In some cases, you might need to use an inner subquery that references a value in the outer query.
-- Conceptually, the inner query runs once for each row returned by the outer query
-- (which is why correlated subqueries are sometimes referred to as repeating subqueries).

-- A simple query
SELECT od.SalesOrderID, od.ProductID, od.OrderQty
FROM SalesLT.SalesOrderDetail AS od
ORDER BY od.ProductID;

-- The inner query references a table declared in the outer query
SELECT od.SalesOrderID, od.ProductID, od.OrderQty
FROM SalesLT.SalesOrderDetail AS od
WHERE od.OrderQty =
    (SELECT MAX(OrderQty)
    FROM SalesLT.SalesOrderDetail AS d
    WHERE od.ProductID = d.ProductID)
ORDER BY od.ProductID;

-- Another simple query
SELECT o.SalesOrderID, o.OrderDate, o.CustomerID
FROM SalesLT.SalesOrderHeader AS o
ORDER BY o.SalesOrderID;

--
SELECT o.SalesOrderID, o.OrderDate,
    (SELECT CompanyName
    FROM SalesLT.Customer AS c
    WHERE c.CustomerID = o.CustomerID) AS CompanyName
FROM SalesLT.SalesOrderHeader AS o
ORDER BY o.SalesOrderID;


-------------
-- Challenges
-------------

----------------------------------------------------
-- Challenge 1: Retrieve product price information
----------------------------------------------------

-- Adventure Works products each have a standard cost price that indicates the cost of manufacturing the product, and a list price that indicates the recommended selling price for the product. This data is stored in the SalesLT.Product table. Whenever a product is ordered, the actual unit price at which it was sold is also recorded in the SalesLT.SalesOrderDetail table. You must use subqueries to compare the cost and list prices for each product with the unit prices charged in each sale.

-- 1. Retrieve products whose list price is higher than the average unit price.
--      Retrieve the product ID, name, and list price for each product where the list price is higher than the average unit price for all products that have been sold.
--      Tip: Use the AVG function to retrieve an average value.
-- 2. Retrieve Products with a list price of 100 or more that have been sold for less than 100.
--      Retrieve the product ID, name, and list price for each product where the list price is 100 or more, and the product has been sold for less than 100.

-- SOLUTIONS

---------------------------------------
-- Challenge 1: Analyze profitability
---------------------------------------

-- The standard cost of a product and the unit price at which it is sold determine its profitability. You must use correlated subqueries to compare the cost and average selling price for each product.

--     Retrieve the cost, list price, and average selling price for each product
--         Retrieve the product ID, name, cost, and list price for each product along with the average unit price for which that product has been sold.
--     Retrieve products that have an average selling price that is lower than the cost.
--         Filter your previous query to include only products where the cost price is higher than the average selling price.

-- SOLUTIONS

-- SOLUTIONS move after completing any exercice

-- 1.1
SELECT ProductID, Name, ListPrice
FROM SalesLT.Product
WHERE ListPrice >
    (SELECT AVG(UnitPrice)
    FROM SalesLT.SalesOrderDetail)
ORDER BY ProductID;


-- 1.2
SELECT ProductID, Name, ListPrice
FROM SalesLT.Product
WHERE ProductID IN
    (SELECT ProductID
    FROM SalesLT.SalesOrderDetail
    WHERE UnitPrice < 100.00)
AND ListPrice >= 100.00
ORDER BY ProductID;

-- 2.1
SELECT p.ProductID, p.Name, p.StandardCost, p.ListPrice,
    (SELECT AVG(o.UnitPrice)
    FROM SalesLT.SalesOrderDetail AS o
    WHERE p.ProductID = o.ProductID) AS AvgSellingPrice
FROM SalesLT.Product AS p
ORDER BY p.ProductID;

-- 2.2
SELECT p.ProductID, p.Name, p.StandardCost, p.ListPrice,
    (SELECT AVG(o.UnitPrice)
    FROM SalesLT.SalesOrderDetail AS o
    WHERE p.ProductID = o.ProductID) AS AvgSellingPrice
FROM SalesLT.Product AS p
WHERE StandardCost >
    (SELECT AVG(od.UnitPrice)
    FROM SalesLT.SalesOrderDetail AS od
    WHERE p.ProductID = od.ProductID)
ORDER BY p.ProductID;
