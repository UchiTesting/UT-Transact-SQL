-- ----------------------------------------------------------------------
-- This section goes with the following page
-- https://learn.microsoft.com/en-us/training/modules/modify-data-with-transact-sql/7-exercise-modify-data/
--
-- MODIFY DATA WITH T-SQL
-- ----------------------------------------------------------------------

--------------------------------------
-- Chapter Insert data
--------------------------------------

-- Optionally run this if table still exists
DROP TABLE IF EXISTS SalesLT.#CallLog;

-- Create a temporary table to work on
CREATE TABLE SalesLT.#CallLog
(
    CallID int IDENTITY PRIMARY KEY NOT NULL,
    CallTime datetime NOT NULL DEFAULT GETDATE(),
    SalesPerson nvarchar(256) NOT NULL,
    CustomerID int NOT NULL REFERENCES SalesLT.Customer(CustomerID),
    PhoneNumber nvarchar(25) NOT NULL,
    Notes nvarchar(max) NULL
);

-- Check it returns headers. No line has been inserted yet
SELECT * FROM SalesLT.#CallLog;

-- Insert a single line
INSERT INTO SalesLT.#CallLog
VALUES
('2015-01-01T12:30:00', 'adventure-works\pamela0', 1, '245-555-0173', 'Returning call re: enquiry about delivery');

-- Insert a single line using DEFAULT and NULL
INSERT INTO SalesLT.#CallLog
VALUES
(DEFAULT, 'adventure-works\david8', 2, '170-555-0127', NULL);

-- Insert a 3rd line
INSERT INTO SalesLT.#CallLog (SalesPerson, CustomerID, PhoneNumber)
VALUES
('adventure-works\jillian0', 3, '279-555-0130');

-- Insert multiple lines at once
INSERT INTO SalesLT.#CallLog
VALUES
(DATEADD(mi,-2, GETDATE()), 'adventure-works\jillian0', 4, '710-555-0173', NULL),
(DEFAULT, 'adventure-works\shu0', 5, '828-555-0186', 'Called to arrange deliver of order 10987');

-- Insert lines from another table
INSERT INTO SalesLT.#CallLog (SalesPerson, CustomerID, PhoneNumber, Notes)
SELECT SalesPerson, CustomerID, Phone, 'Sales promotion call'
FROM adventureworks.SalesLT.Customer -- I don't know why I had to add the DB name for it to work
WHERE CompanyName = 'Big-Time Bike Store';

-- Add another line
INSERT INTO SalesLT.#CallLog (SalesPerson, CustomerID, PhoneNumber)
VALUES
('adventure-works\josé1', 10, '150-555-0127');

-- Show the last used identity
-- SCOPE_IDENTITY is for DB at all
-- IDENT_CURENT is for specified table
SELECT SCOPE_IDENTITY() AS LatestIdentityInDB,
    IDENT_CURRENT('SalesLT.#CallLog') AS LatestCallID;

-- Allow manually setting the identity value
SET IDENTITY_INSERT SalesLT.#CallLog ON;

INSERT INTO SalesLT.#CallLog (CallID, SalesPerson, CustomerID, PhoneNumber)
VALUES
(20, 'adventure-works\josé1', 11, '926-555-0159');

SET IDENTITY_INSERT SalesLT.#CallLog OFF;

--------------------------------------
-- Chapter Update data
--------------------------------------

-- UPdate line with no notes to "No notes"
UPDATE SalesLT.#CallLog
SET Notes = 'No notes'
WHERE Notes IS NULL;

-- Showcase the danger of using UPDATE without filtering
UPDATE SalesLT.#CallLog
SET SalesPerson = '', PhoneNumber = '';

-- Restore previously removed data from another table
UPDATE SalesLT.#CallLog
SET SalesPerson = c.SalesPerson, PhoneNumber = c.Phone
FROM adventureworks.SalesLT.Customer AS c
WHERE c.CustomerID = SalesLT.#CallLog.CustomerID;

--------------------------------------
-- Chapter Delete data
--------------------------------------

-- Deleting rows matching a condition
DELETE FROM SalesLT.#CallLog
WHERE CallTime < DATEADD(dd, -7, GETDATE());

-- Clear the table from any data
TRUNCATE TABLE SalesLT.#CallLog;

-------------
-- Challenges
-------------

---------------------------------
-- Challenge 1: Insert products
---------------------------------

-- Each Adventure Works product is stored in the SalesLT.Product table, and each product has a unique ProductID identifier, which is implemented as an identity column in the SalesLT.Product table. Products are organized into categories, which are defined in the SalesLT.ProductCategory table. The products and product category records are related by a common ProductCategoryID identifier, which is an identity column in the SalesLT.ProductCategory table.

-- 1. Insert a product
--      Adventure Works has started selling the following new product. Insert it into the SalesLT.Product table, using default or NULL values for unspecified columns:
--        Name: LED Lights
--        ProductNumber: LT-L123
--        StandardCost: 2.56
--        ListPrice: 12.99
--        ProductCategoryID: 37
--        SellStartDate: Today’s date
--      After you have inserted the product, run a query to determine the ProductID that was generated.
--      Then run a query to view the row for the product in the SalesLT.Product table.
-- 2. Insert a new category with two products
--      Adventure Works is adding a product category for Bells and Horns to its catalog. The parent category for the new category is 4 (Accessories). This new category includes the following two new products:
--        First product:
--                 Name: Bicycle Bell
--                 ProductNumber: BB-RING
--                 StandardCost: 2.47
--                 ListPrice: 4.99
--                 ProductCategoryID: The ProductCategoryID for the new Bells and Horns category
--                 SellStartDate: Today’s date
--        Second product:
--                 Name: Bicycle Horn
--                 ProductNumber: BB-PARP
--                 StandardCost: 1.29
--                 ListPrice: 3.75
--                 ProductCategoryID: The ProductCategoryID for the new Bells and Horns category
--                 SellStartDate: Today’s date
--      Write a query to insert the new product category, and then insert the two new products with the appropriate ProductCategoryID value.
--      After you have inserted the products, query the SalesLT.Product and SalesLT.ProductCategory tables to verify that the data has been inserted.

-- SOLUTIONS

---------------------------------
-- Challenge 2: Update products
---------------------------------

-- You have inserted data for a product, but the pricing details are not correct. You must now update the records you have previously inserted to reflect the correct pricing. Tip: Review the documentation for UPDATE in the Transact-SQL Language Reference.

-- 1. Update product prices
--      The sales manager at Adventure Works has mandated a 10% price increase for all products in the Bells and Horns category. Update the rows in the SalesLT.Product table for these products to increase their price by 10%.
-- 2. Discontinue products
--      The new LED lights you inserted in the previous challenge are to replace all previous light products. Update the SalesLT.Product table to set the DiscontinuedDate to today’s date for all products in the Lights category (product category ID 37) other than the LED Lights product you inserted previously.

-- SOLUTIONS

---------------------------------
-- Challenge 3: Delete products
---------------------------------

-- The Bells and Horns category has not been successful, and it must be deleted from the database.

-- 1. Delete a product category and its products
--      Delete the records for the Bells and Horns category and its products. You must ensure that you delete the records from the tables in the correct order to avoid a foreign-key constraint violation.

-- SOLUTIONS

-- SOLUTIONS TO MOVE AFTER ANY CHALLENGE HAVE BEEN COMPLETED

-- 1.1
INSERT INTO SalesLT.Product (Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate)
VALUES
('LED Lights', 'LT-L123', 2.56, 12.99, 37, GETDATE());

SELECT SCOPE_IDENTITY();

SELECT * FROM SalesLT.Product
WHERE ProductID = SCOPE_IDENTITY();

-- 1.2
INSERT INTO SalesLT.ProductCategory (ParentProductCategoryID, Name)
VALUES
(4, 'Bells and Horns');

INSERT INTO SalesLT.Product (Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate)
VALUES
('Bicycle Bell', 'BB-RING', 2.47, 4.99, IDENT_CURRENT('SalesLT.ProductCategory'), GETDATE()),
('Bicycle Horn', 'BH-PARP', 1.29, 3.75, IDENT_CURRENT('SalesLT.ProductCategory'), GETDATE());

SELECT c.Name As Category, p.Name AS Product
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory as c
    ON p.ProductCategoryID = c.ProductCategoryID
WHERE p.ProductCategoryID = IDENT_CURRENT('SalesLT.ProductCategory');

-- 2.1
UPDATE SalesLT.Product
SET ListPrice = ListPrice * 1.1
WHERE ProductCategoryID =
    (SELECT ProductCategoryID
    FROM SalesLT.ProductCategory
    WHERE Name = 'Bells and Horns');

-- 2.2
UPDATE SalesLT.Product
SET DiscontinuedDate = GETDATE()
WHERE ProductCategoryID = 37
AND ProductNumber <> 'LT-L123';

-- 3.1
DELETE FROM SalesLT.Product
WHERE ProductCategoryID =
    (SELECT ProductCategoryID
    FROM SalesLT.ProductCategory
    WHERE Name = 'Bells and Horns');

DELETE FROM SalesLT.ProductCategory
WHERE ProductCategoryID =
    (SELECT ProductCategoryID
    FROM SalesLT.ProductCategory
    WHERE Name = 'Bells and Horns');
