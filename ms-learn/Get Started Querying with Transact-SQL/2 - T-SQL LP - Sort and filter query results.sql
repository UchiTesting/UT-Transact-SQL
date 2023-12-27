-- ----------------------------------------------------------------------
-- This section goes with the following page
-- https://learn.microsoft.com/en-us/training/modules/sort-filter-queries/7-exercise-sort-filter-query-results/
-- 
-- SORT AND FILTER QUERY RESULTS
-- ----------------------------------------------------------------------

-----------------------------------------
-- Sort results using the ORDER BY clause
-----------------------------------------

-- Order by name
SELECT Name, ListPrice
FROM SalesLT.Product
ORDER BY Name;

-- Order by ListPrice
SELECT Name, ListPrice
FROM SalesLT.Product
ORDER BY ListPrice;

-- Order by ListPrice descending
SELECT Name, ListPrice
FROM SalesLT.Product
ORDER BY ListPrice DESC;

-- Order by ListPrice descending first then name ascending
SELECT Name, ListPrice
FROM SalesLT.Product
ORDER BY ListPrice DESC, Name ASC;

-------------------------------
-- Restrict results using TOP
-------------------------------

-- Limit to 20 results
SELECT TOP (20) Name, ListPrice
FROM SalesLT.Product
ORDER BY ListPrice DESC;

-- Limit to 20 results but can actually return more rows because of tie results
-- i.e. should any result beyond the defined limit share the same value on order column
-- they will also be displayed. Try limiting to 7 items for instance. 9 will be displayed.
SELECT TOP (20) WITH TIES Name, ListPrice
FROM SalesLT.Product
ORDER BY ListPrice DESC;

-- Changes the unit from rows to %
SELECT TOP (20) PERCENT WITH TIES Name, ListPrice
FROM SalesLT.Product
ORDER BY ListPrice DESC;

----------------------------------------------------
-- Retrieve pages of results with OFFSET and FETCH
----------------------------------------------------

-- Fetch the 10 1st rows in the result set
SELECT Name, ListPrice
FROM SalesLT.Product
ORDER BY Name OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- Fetch 10 results starting from 11th rows
SELECT Name, ListPrice
FROM SalesLT.Product
ORDER BY Name OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;

-------------------------------------
-- Use the ALL and DISTINCT options
-------------------------------------

-- Select Color. Shows values are repeated
SELECT Color
FROM SalesLT.Product;

-- Same result as above. Proves ALL is the implicit default behaviour
-- Returns a row if it meets the query criteria
SELECT ALL Color
FROM SalesLT.Product;

-- Returns only the different values once
SELECT DISTINCT Color
FROM SalesLT.Product;

-- If several columns are defined, it returns unique combinations
SELECT DISTINCT Color, Size
FROM SalesLT.Product;

-----------------------------------------
-- Filter results with the WHERE clause
-----------------------------------------

--
SELECT Name, Color, Size
FROM SalesLT.Product
WHERE ProductModelID = 6
ORDER BY Name;

--
SELECT Name, Color, Size
FROM SalesLT.Product
WHERE ProductModelID <> 6
ORDER BY Name;

--
SELECT Name, ListPrice
FROM SalesLT.Product
WHERE ListPrice > 1000.00
ORDER BY ListPrice;

--
SELECT Name, ListPrice
FROM SalesLT.Product
WHERE Name LIKE 'HL Road Frame %';

-- LIKE with a complex pattern
-- More info at https://learn.microsoft.com/fr-fr/sql/t-sql/language-elements/like-transact-sql?view=sql-server-ver16
SELECT Name, ListPrice, ProductNumber
FROM SalesLT.Product
WHERE ProductNumber LIKE 'FR-_[0-9][0-9]_-[0-9][0-9]';

--
SELECT Name, ListPrice
FROM SalesLT.Product
WHERE SellEndDate IS NOT NULL;

--
SELECT Name
FROM SalesLT.Product
WHERE SellEndDate BETWEEN '2006/1/1' AND '2006/12/31';

--
SELECT ProductCategoryID, Name, ListPrice
FROM SalesLT.Product
WHERE ProductCategoryID IN (5,6,7);

-- AND
SELECT ProductCategoryID, Name, ListPrice, SellEndDate
FROM SalesLT.Product
WHERE ProductCategoryID IN (5,6,7) AND SellEndDate IS NULL;

-- OR
SELECT Name, ProductCategoryID, ProductNumber
FROM SalesLT.Product
WHERE ProductNumber LIKE 'FR%' OR ProductCategoryID IN (5,6,7);

-------------
-- Challenges
-------------

----------------------------------------------------------
-- Challenge 1: Retrieve data for transportation reports
----------------------------------------------------------
-- The logistics manager at Adventure Works has asked you to generate 
-- some reports containing details of the company’s customers to help to reduce
-- transportation costs.

--   1.  Retrieve a list of cities
--         Initially, you need to produce a list of all of you customers' locations. Write a Transact-SQL query that queries the SalesLT.Address table and retrieves the values for City and StateProvince, removing duplicates and sorted in ascending order of city.
--   2.  Retrieve the heaviest products
--         Transportation costs are increasing and you need to identify the heaviest products. Retrieve the names of the top ten percent of products by weight.

-- 1.
SELECT DISTINCT City, StateProvince
FROM SalesLT.Address
ORDER BY City

--2.
-- Did not put parentheses but not mandatory. Any reason to do it ?
-- Did not use WITH TIES. Both queries return 30 rows
SELECT TOP 10 PERCENT Name 
FROM SalesLT.Product
ORDER BY Weight DESC

-- SOLUTIONS

-- 1.1
SELECT DISTINCT City, StateProvince
FROM SalesLT.Address
ORDER BY City

-- 1.2
SELECT TOP (10) PERCENT WITH TIES Name
FROM SalesLT.Product
ORDER BY Weight DESC;

---------------------------------------
-- Challenge 2: Retrieve product data
---------------------------------------
-- The Production Manager at Adventure Works would like you to create
-- some reports listing details of the products that you sell.

--   1.  Retrieve product details for product model 1
--         Initially, you need to find the names, colors, and sizes of the products with a product model ID 1.
--   2.  Filter products by color and size
--         Retrieve the product number and name of the products that have a color of black, red, or white and a size of S or M.
--   3.  Filter products by product number
--         Retrieve the product number, name, and list price of products whose product number begins BK-
--   4.  Retrieve specific products by product number
--         Modify your previous query to retrieve the product number, name, and list price of products whose product number begins BK- followed by any character other than R, and ends with a - followed by any two numerals.


-- 1.
SELECT [Name], [Color], [Size]
FROM SalesLT.Product
WHERE ProductModelID = 1

-- 2.
SELECT ProductNumber, Name
FROM SalesLT.Product
WHERE Color IN ('Red','Black','White')
    AND Size IN ('S','M')

-- This extra query explains why there is no result with Red colour
-- No size is S or M or a letter anyway
SELECT ProductNumber, Name,Color,[Size]
FROM SalesLT.Product
WHERE Color='Red'

-- 3.
SELECT ProductNumber, Name, ListPrice
FROM SalesLT.Product
WHERE ProductNumber LIKE 'BK-%'

-- 4.
SELECT ProductNumber, Name, ListPrice
FROM SalesLT.Product
WHERE ProductNumber LIKE 'BK-[^R]%-[0-9][0-9]'

-- SOLUTIONS

-- 2.1
SELECT Name, Color, Size
FROM SalesLT.Product
WHERE ProductModelID = 1;

-- 2.2
SELECT ProductNumber, Name
FROM SalesLT.Product
WHERE Color IN ('Black','Red','White') AND Size IN ('S','M');

-- 2.3
SELECT ProductNumber, Name, ListPrice
FROM SalesLT.Product
WHERE ProductNumber LIKE 'BK-%';

-- 4.
SELECT ProductNumber, Name, ListPrice
FROM SalesLT.Product
WHERE ProductNumber LIKE 'BK-[^R]%-[0-9][0-9]';
