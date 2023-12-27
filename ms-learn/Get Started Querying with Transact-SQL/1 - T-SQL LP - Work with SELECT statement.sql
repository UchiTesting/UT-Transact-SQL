-- ----------------------------------------------------------------------
-- This section goes with the following page
-- https://learn.microsoft.com/en-us/training/modules/introduction-to-transact-sql/6-exercise-work-with-select-statements
--
-- WORK WITH SELECT STATEMENTS
-- ----------------------------------------------------------------------

--------------------------------------
-- Use SELECT queries to retrieve data
--------------------------------------

-- Select All the columns in the table
SELECT * FROM SalesLT.Product;

-- Specify as et of expected columns explicitely
SELECT Name, StandardCost, ListPrice
FROM SalesLT.Product;

-- Use of a calculated column
SELECT Name, ListPrice - StandardCost as CalculatedColumn
FROM SalesLT.Product;

-- Column Aliases
SELECT Name AS ProductName, ListPrice - StandardCost AS Markup
FROM SalesLT.Product;

-- Alias and calculated column
SELECT ProductNumber, Color, Size, Color + ', ' + Size AS ProductDetails
FROM SalesLT.Product;

-----------------------
-- Work with data types
-----------------------

-- Conversion failure demo
SELECT ProductID + ': ' + Name AS ProductName
FROM SalesLT.Product; 

-- Fixing the issue with explicit cast
SELECT CAST(ProductID AS varchar(5)) + ': ' + Name AS ProductName
FROM SalesLT.Product; 

-- Equivalent with CONVERT
SELECT CONVERT(varchar(5), ProductID) + ': ' + Name AS ProductName
FROM SalesLT.Product; 

-- Providing formatting information in the 3rd param
SELECT SellStartDate,
   CONVERT(nvarchar(30), SellStartDate) AS ConvertedDate,
    CONVERT(nvarchar(30), SellStartDate, 126) AS ISO8601FormatDate
FROM SalesLT.Product; 

-- Observe that some of the values cannot be converted to numeric
SELECT DISTINCT Size
FROM SalesLT.Product
ORDER BY Size DESC

-- This cause an error in this query
SELECT Name, CAST(Size AS Integer) AS NumericSize
FROM SalesLT.Product; 

-- TRY_CAST will allow the query to execute by replacing non compatible values with NULL
SELECT Name, TRY_CAST(Size AS Integer) AS NumericSize
FROM SalesLT.Product; 

---------------------
-- Handle NULL values
---------------------

-- ISNULL allows to replace any NULL with a representative value
SELECT Name, ISNULL(TRY_CAST(Size AS Integer),0) AS NumericSize
FROM SalesLT.Product;

-- ISNULL to replace NULL directly from data
SELECT ProductNumber, ISNULL(Color, '') + ', ' + ISNULL(Size, '') AS ProductDetails
FROM SalesLT.Product;

-- NULLIF does the opposite by returning NULL when the value matches param 2
SELECT Name, NULLIF(Color, 'Multi') AS SingleColor
FROM SalesLT.Product;

-- COALESCE Return the 1st expression that is not NULL
SELECT Name, COALESCE(SellEndDate, SellStartDate) AS StatusLastUpdated
FROM SalesLT.Product;

-- Displays different values as SalesStatus depending on an expression check
SELECT Name,
    CASE
        WHEN SellEndDate IS NULL THEN 'Currently for sale'
        ELSE 'No longer available'
    END AS SalesStatus
FROM SalesLT.Product;

-- Further demo of CASE
SELECT Name,
    CASE Size
        WHEN 'S' THEN 'Small'
        WHEN 'M' THEN 'Medium'
        WHEN 'L' THEN 'Large'
        WHEN 'XL' THEN 'Extra-Large'
        -- Behaves like a ternary operator kind of like
        -- C# : (Size is null) ? Size.ToString() : "n/a";
        ELSE ISNULL(Size, 'n/a') 
    END AS ProductSize
FROM SalesLT.Product;

-------------
-- Challenges
-------------

--------------------------------------
-- Challenge 1: Retrieve customer data
--------------------------------------
-- Adventure Works Cycles sells directly to retailers, who then sell products to consumers. 
-- Each retailer that is an Adventure Works customer has provided a named contact for all communication from Adventure Works. 
-- The sales manager at Adventure Works has asked you to generate some reports containing details of the company’s customers to support a direct sales campaign.

--     Retrieve customer details
--         Familiarize yourself with the SalesLT.Customer table by writing a Transact-SQL query that retrieves all columns for all customers.
--     Retrieve customer name data
--         Create a list of all customer contact names that includes the title, first name, middle name (if any), last name, and suffix (if any) of all customers.
--     Retrieve customer names and phone numbers
--         Each customer has an assigned salesperson. You must write a query to create a call sheet that lists:
--             The salesperson
--             A column named CustomerName that displays how the customer contact should be greeted (for example, Mr Smith)
--             The customer’s phone number.


-- List Tables for the sake of seeing where data could be.
-- No SHOW TABLES just like MySQL in T-SQL :/
SELECT name FROM Sys.Tables;

-- 1st question
SELECT * FROM SalesLT.Customer;

-- 2nd question
SELECT Title, FirstName, 
CASE 
    WHEN MiddleName IS NULL THEN ''
    ELSE MiddleName
END AS MiddleName,
LastName, 
CASE
    WHEN Suffix IS NULL THEN ''
    ELSE Suffix
END AS Suffix
FROM SalesLT.Customer;

-- 3rd question
SELECT SalesPerson, CONCAT(Title, ' ', FirstName, ' ', LastName) AS CustomerName, Phone
From SalesLT.Customer

-- SOLUTIONS

-- Q1 Excellent
SELECT * FROM SalesLT.Customer;

-- Q2 Did overcomplicate but the instruction mentioned "if any" to some columns.
-- Expected is too easy.
SELECT Title, FirstName, MiddleName, LastName, Suffix
FROM SalesLT.Customer;

-- Q3 Pretty close. My result differs by having extra FirstName
-- In this case nothing tells to pay attention to Title being possibly NULL
SELECT Salesperson, ISNULL(Title,'') + ' ' + LastName AS CustomerName, Phone
FROM SalesLT.Customer;

--------------------------------------------
-- Challenge 2: Retrieve customer order data
--------------------------------------------

-- As you continue to work with the Adventure Works customer data, you must create queries for reports that have been requested by the sales team.

--     Retrieve a list of customer companies
--         You have been asked to provide a list of all customer companies in the format Customer ID : Company Name - for example, 78: Preferred Bikes.
--     Retrieve a list of sales order revisions
--         The SalesLT.SalesOrderHeader table contains records of sales orders. You have been asked to retrieve data for a report that shows:
--             The sales order number and revision number in the format () – for example SO71774 (2).
--             The order date converted to ANSI standard 102 format (yyyy.mm.dd – for example 2015.01.31).

--


SELECT  CONCAT(CustomerID,': ', CompanyName)
FROM SalesLT.Customer

SELECT SalesOrderNumber +' (' + CONVERT(varchar, RevisionNumber) + ')', FORMAT(OrderDate,'yyyy.MM.dd')
FROM SalesLT.SalesOrderHeader


-- SOLUTIONS

-- 1. Retrieve a list of customers company

SELECT CAST(CustomerID AS varchar) + ': ' + CompanyName AS CustomerCompany
FROM SalesLT.Customer;

-- 2. Retrieve a list of sales order revisions

SELECT SalesOrderNumber + ' (' + STR(RevisionNumber, 1) + ')' AS OrderRevision,
   CONVERT(nvarchar(30), OrderDate, 102) AS OrderDate
FROM SalesLT.SalesOrderHeader;

-------------------------------------------------
-- Challenge 3: Retrieve customer contact details
-------------------------------------------------

-- Some records in the database include missing or unknown values that are returned as NULL. You must create some queries that handle these NULL values appropriately.

--     Retrieve customer contact names with middle names if known
--         You have been asked to write a query that returns a list of customer names. The list must consist of a single column in the format first last (for example Keith Harris) if the middle name is unknown, or first middle last (for example Jane M. Gates) if a middle name is known.

--     Retrieve primary contact details

--         Customers may provide Adventure Works with an email address, a phone number, or both. If an email address is available, then it should be used as the primary contact method; if not, then the phone number should be used. You must write a query that returns a list of customer IDs in one column, and a second column named PrimaryContact that contains the email address if known, and otherwise the phone number.

--         IMPORTANT: In the sample data provided, there are no customer records without an email address. Therefore, to verify that your query works as expected, run the following UPDATE statement to remove some existing email addresses before creating your query:

--         sql
--         UPDATE SalesLT.Customer
--         SET EmailAddress = NULL
--         WHERE CustomerID % 7 = 1;

--     Retrieve shipping status

--         You have been asked to create a query that returns a list of sales order IDs and order dates with a column named ShippingStatus that contains the text Shipped for orders with a known ship date, and Awaiting Shipment for orders with no ship date.

--         IMPORTANT: In the sample data provided, there are no sales order header records without a ship date. Therefore, to verify that your query works as expected, run the following UPDATE statement to remove some existing ship dates before creating your query.

--         sql
--         UPDATE SalesLT.SalesOrderHeader
--         SET ShipDate = NULL
--         WHERE SalesOrderID > 71899;

SELECT FirstName +  
CASE 
    WHEN MiddleName IS NULL THEN ''
    ELSE ' '+ MiddleName
END  + ' ' + LastName
FROM SalesLT.Customer

SELECT COALESCE(EmailAddress, Phone) As PrimaryContact
FROM SalesLT.Customer

-- SOLUTIONS

-- 1. Retrieve customer contact names with middle names if known:

SELECT FirstName + ' ' + ISNULL(MiddleName + ' ', '') + LastName AS CustomerName
FROM SalesLT.Customer;

-- 2. Retrieve primary contact details:

SELECT CustomerID, COALESCE(EmailAddress, Phone) AS PrimaryContact
FROM SalesLT.Customer;

-- 3. Retrieve shipping status:

SELECT SalesOrderID, OrderDate,
    CASE
        WHEN ShipDate IS NULL THEN 'Awaiting Shipment'
        ELSE 'Shipped'
    END AS ShippingStatus
FROM SalesLT.SalesOrderHeader;
