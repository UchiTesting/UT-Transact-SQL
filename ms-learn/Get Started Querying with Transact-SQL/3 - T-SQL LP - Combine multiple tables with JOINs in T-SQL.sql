-- ----------------------------------------------------------------------
-- This section goes with the following page
-- https://learn.microsoft.com/en-us/training/modules/query-multiple-tables-with-joins/6-exercise-query-with-joins/
-- 
-- COMBINE MULTIPLE TABLES WITH JOINS IN T-SQL
-- ----------------------------------------------------------------------

--------------------------------------
-- Chapter Use Inner Joins
--------------------------------------

-- Products without category are not shown
-- Categories with no product are not shown neither
SELECT SalesLT.Product.Name AS ProductName, SalesLT.ProductCategory.Name AS Category
FROM SalesLT.Product
INNER JOIN SalesLT.ProductCategory
ON SalesLT.Product.ProductCategoryID = SalesLT.ProductCategory.ProductCategoryID;

-- Same as above but without the INNER keyword.
-- INNER is implicit default
SELECT SalesLT.Product.Name AS ProductName, SalesLT.ProductCategory.Name AS Category
FROM SalesLT.Product
JOIN SalesLT.ProductCategory
    ON SalesLT.Product.ProductCategoryID = SalesLT.ProductCategory.ProductCategoryID;

-- Can use aliases on tables and columns to better identify them
SELECT p.Name AS ProductName, c.Name AS Category
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory AS c
    ON p.ProductCategoryID = c.ProductCategoryID;

-- Join more than 2 tables
-- oh <> od <> p
SELECT oh.OrderDate, oh.SalesOrderNumber, p.Name AS ProductName, od.OrderQty, od.UnitPrice, od.LineTotal
FROM SalesLT.SalesOrderHeader AS oh
JOIN SalesLT.SalesOrderDetail AS od
    ON od.SalesOrderID = oh.SalesOrderID
JOIN SalesLT.Product AS p
    ON od.ProductID = p.ProductID
ORDER BY oh.OrderDate, oh.SalesOrderID, od.SalesOrderDetailID;

--------------------------------------
-- Chapter Use Outer Joins
--------------------------------------

-- LEFT join designates SalesLT.Customer table because it is on the left of the statement (should the query be written on a single line)
-- This means SalesLT.Customer is the outer table from which every row is returned.
-- Should there be no match for oh.SalesOrderNumber column, it will display as NULL
--
-- Using RIGHT instead of LEFT would do the opposite
-- Using FULL instead of LEFT/RIGHT would combine both behaviours
-- i.e. 
-- There could be lines matching,
-- lines with data for Customer Data only and NULL for oh.SalesOrderNumber
-- lines with no data for Customer Data that would appear as NULL while there is data for oh.SalesOrderNumber
SELECT c.FirstName, c.LastName, oh.SalesOrderNumber
FROM SalesLT.Customer AS c
LEFT OUTER JOIN SalesLT.SalesOrderHeader AS oh
    ON c.CustomerID = oh.CustomerID
ORDER BY c.CustomerID;


-- Same but no OUTER keyword
-- OUTER is implicit with either LEFT, RIGHT, FULL
SELECT c.FirstName, c.LastName, oh.SalesOrderNumber
FROM SalesLT.Customer AS c
LEFT JOIN SalesLT.SalesOrderHeader AS oh
    ON c.CustomerID = oh.CustomerID
ORDER BY c.CustomerID;


-- Returns only line where oh.SalesOrderNumber is not null
SELECT c.FirstName, c.LastName, oh.SalesOrderNumber
FROM SalesLT.Customer AS c
LEFT JOIN SalesLT.SalesOrderHeader AS oh
    ON c.CustomerID = oh.CustomerID
WHERE oh.SalesOrderNumber IS NOT NULL 
ORDER BY c.CustomerID;

-- Outer joins on multiple tables
-- p <> od <> oh
SELECT p.Name As ProductName, oh.SalesOrderNumber
FROM SalesLT.Product AS p
LEFT JOIN SalesLT.SalesOrderDetail AS od
    ON p.ProductID = od.ProductID
LEFT JOIN SalesLT.SalesOrderHeader AS oh
    ON od.SalesOrderID = oh.SalesOrderID
ORDER BY p.ProductID;

-- INNER and OUTER joins
-- In such case be explicit on join type
SELECT p.Name As ProductName, c.Name AS Category, oh.SalesOrderNumber
FROM SalesLT.Product AS p
LEFT OUTER JOIN SalesLT.SalesOrderDetail AS od
    ON p.ProductID = od.ProductID
LEFT OUTER JOIN SalesLT.SalesOrderHeader AS oh
    ON od.SalesOrderID = oh.SalesOrderID
INNER JOIN SalesLT.ProductCategory AS c
    ON p.ProductCategoryID = c.ProductCategoryID
ORDER BY p.ProductID;

--------------------------------------
-- Chapter Use Cross Joins
--------------------------------------

-- Simpley cross every data from table A with every data from table B
SELECT p.Name, c.FirstName, c.LastName, c.EmailAddress
FROM SalesLT.Product AS p
CROSS JOIN SalesLT.Customer AS c;


--------------------------------------
-- Chapter Use Self Joins
--------------------------------------

-- A self join isn’t actually a specific kind of join, but it’s a technique used
-- to join a table to itself by defining two instances of the table,
-- each with its own alias. This approach can be useful
-- when a row in the table includes a foreign key field that references the primary key of the same table;
-- for example in a table of employees where an employee’s manager is also an employee,
-- or a table of product categories where each category might be a subcategory of another category.

SELECT pcat.Name AS ParentCategory, cat.Name AS SubCategory
FROM SalesLT.ProductCategory AS cat
JOIN SalesLT.ProductCategory pcat
    ON cat.ParentProductCategoryID = pcat.ProductCategoryID
ORDER BY ParentCategory, SubCategory;


-------------
-- Challenges
-------------

------------------------------------------
-- Challenge 1: Generate invoice reports
------------------------------------------

-- Adventure Works Cycles sells directly to retailers, who must be invoiced for their orders. You have been tasked with writing a query to generate a list of invoices to be sent to customers.

-- 1. Retrieve customer orders
--      As an initial step towards generating the invoice report, write a query that returns the company name from the SalesLT.Customer table, and the sales order ID and total due from the SalesLT.SalesOrderHeader table.
-- 2. Retrieve customer orders with addresses
--      Extend your customer orders query to include the Main Office address for each customer, including the full street address, city, state or province, postal code, and country or region
--      Tip: Note that each customer can have multiple addressees in the SalesLT.Address table, so the database developer has created the SalesLT.CustomerAddress table to enable a many-to-many relationship between customers and addresses. Your query will need to include both of these tables, and should filter the results so that only Main Office addresses are included.

-- 1.
SELECT DISTINCT c.CompanyName, oh.SalesOrderID, oh.TotalDue
FROM SalesLT.Customer AS c
JOIN SalesLT.SalesOrderHeader AS oh
    ON c.CustomerID = oh.CustomerID
-- Why on Earth did I join those extra tables?
-- This forced me to use DISTINCT
-- JOIN SalesLT.SalesOrderDetail AS od
--     ON oh.SalesOrderID = od.SalesOrderID
-- JOIN SalesLT.Product AS p
--     ON od.ProductID = p.ProductID

-- 2.
SELECT c.CompanyName, oh.SalesOrderID, oh.TotalDue, 
-- They did not CONCAT the address
-- Also they did a check on AddressLine2 for NULL
-- CONCAT(a.AddressLine1, ' ', a.AddressLine2, ' ', a.City,' ', a.StateProvince, ' ', a.PostalCode, ' ', a.CountryRegion) as MainOffice
CONCAT(a.AddressLine1, ' ', 
-- This solves managing the extra space when the value is NULL
CASE  
    WHEN a.AddressLine2 IS NULL THEN ''
    WHEN a.AddressLine2 IS NOT NULL THEN CONCAT(a.AddressLine2, ' ')
END,
 a.City,' ', a.StateProvince, ' ', a.PostalCode, ' ', a.CountryRegion) as MainOffice
FROM SalesLT.Customer AS c
JOIN SalesLT.SalesOrderHeader AS oh
    ON c.CustomerID = oh.CustomerID
-- JOIN SalesLT.SalesOrderDetail AS od
--     ON oh.SalesOrderID = od.SalesOrderID
-- JOIN SalesLT.Product AS p
--     ON od.ProductID = p.ProductID
JOIN SalesLT.CustomerAddress AS ca
    ON ca.CustomerID = c.CustomerID
JOIN SalesLT.Address AS a
    ON a.AddressID = ca.AddressID
WHERE ca.AddressType='Main Office'

-- SOLUTIONS

-- 1.1
SELECT c.CompanyName, oh.SalesOrderID, oh.TotalDue
FROM SalesLT.Customer AS c
JOIN SalesLT.SalesOrderHeader AS oh
    ON oh.CustomerID = c.CustomerID;


-- 1.2
SELECT c.CompanyName,
    a.AddressLine1,
    ISNULL(a.AddressLine2, '') AS AddressLine2,
    a.City,
    a.StateProvince,
    a.PostalCode,
    a.CountryRegion,
    oh.SalesOrderID,
    oh.TotalDue
FROM SalesLT.Customer AS c
JOIN SalesLT.SalesOrderHeader AS oh
    ON oh.CustomerID = c.CustomerID
JOIN SalesLT.CustomerAddress AS ca
    ON c.CustomerID = ca.CustomerID
JOIN SalesLT.Address AS a
    ON ca.AddressID = a.AddressID
WHERE ca.AddressType = 'Main Office';
----------------------------------------
-- Challenge 2: Retrieve customer data
----------------------------------------

-- As you continue to work with the Adventure Works customer and sales data, you must create queries for reports that have been requested by the sales team.

-- 1. Retrieve a list of all customers and their orders
--      The sales manager wants a list of all customer companies and their contacts (first name and last name), showing the sales order ID and total due for each order they have placed. Customers who have not placed any orders should be included at the bottom of the list with NULL values for the order ID and total due.
-- 2. Retrieve a list of customers with no address
--      A sales employee has noticed that Adventure Works does not have address information for all customers. You must write a query that returns a list of customer IDs, company names, contact names (first name and last name), and phone numbers for customers with no address stored in the database.

-- 1.
SELECT c.CompanyName, c.FirstName, c.LastName,
    oh.SalesOrderID, oh.TotalDue
FROM SalesLT.Customer AS c
LEFT JOIN SalesLT.SalesOrderHeader AS oh
    ON oh.CustomerID = c.CustomerID
-- OK but indeed the second order is superfluous
ORDER BY oh.SalesOrderID DESC, oh.TotalDue DESC

-- 2.
SELECT c.CustomerID, c.CompanyName, CONCAT(c.FirstName, ' ', c.LastName) AS ContactName, c.Phone
FROM SalesLT.Customer AS c
LEFT JOIN SalesLT.CustomerAddress AS ca
    ON ca.CustomerID = c.CustomerID
WHERE ca.AddressID IS NULL

-- Alternatively the other way around
SELECT c.CustomerID, c.CompanyName, CONCAT(c.FirstName, ' ', c.LastName) AS ContactName, c.Phone
FROM SalesLT.CustomerAddress AS ca
RIGHT JOIN SalesLT.Customer AS c
    ON c.CustomerID = ca.CustomerID
WHERE CA.AddressID IS NULL

-- SOLUTIONS

-- 2.1
 SELECT c.CompanyName, c.FirstName, c.LastName,
        oh.SalesOrderID, oh.TotalDue
 FROM SalesLT.Customer AS c
 LEFT JOIN SalesLT.SalesOrderHeader AS oh
     ON c.CustomerID = oh.CustomerID
 ORDER BY oh.SalesOrderID DESC;

-- 2.2
 SELECT c.CompanyName, c.FirstName, c.LastName, c.Phone
 FROM SalesLT.Customer AS c
 LEFT JOIN SalesLT.CustomerAddress AS ca
     ON c.CustomerID = ca.CustomerID
 WHERE ca.AddressID IS NULL;

--------------------------------------
-- Challenge 3: challenge title
--------------------------------------

-- Challenge 3: Create a product catalog

-- The marketing team has asked you to retrieve data for a new product catalog.

-- 1. Retrieve product information by category
--      The product catalog will list products by parent category and subcategory, so you must write a query that retrieves the parent category name, subcategory name, and product name fields for the catalog.

-- 1.
SELECT pc.Name AS ParentCategory, sc.Name AS SubCategory, p.Name AS ProductName
FROM SalesLT.Product AS p
-- p <> sc <> pc
JOIN SalesLT.ProductCategory AS sc -- sub category
    ON sc.ProductCategoryID = p.ProductCategoryID
JOIN SalesLT.ProductCategory AS pc -- parent category
    ON pc.ProductCategoryID = sc.ParentProductCategoryID
ORDER BY ParentCategory, SubCategory, ProductName;

-- SOLUTIONS

-- 3.1
 SELECT pcat.Name AS ParentCategory, cat.Name AS SubCategory, prd.Name AS ProductName
 FROM SalesLT.ProductCategory pcat
 -- pcat(pc) <> cat(sc) <> prd(p)
 JOIN SalesLT.ProductCategory AS cat
     ON pcat.ProductCategoryID = cat.ParentProductCategoryID
 JOIN SalesLT.Product AS prd
     ON prd.ProductCategoryID = cat.ProductCategoryID
 ORDER BY ParentCategory, SubCategory, ProductName;

 SELECT * FROM SalesLT.ProductCategory
