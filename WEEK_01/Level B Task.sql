

/*(Use Adventure Works Database)

Create a procedure InsertOrderDetails that takes OrderID, ProductID, UnitPrice, Quantiy, Discount as input parameters and inserts that order information in the Order Details table. After each order inserted, check the @@rowcount value to make sure that order was inserted properly. If for any reason the order was not inserted, print the message: Failed to place the order. Please try again. Also your procedure should have these functionalities

Make the UnitPrice and Discount parameters optional

If no UnitPrice is given, then use the UnitPrice value from the product table.

If no Discount is given, then use a discount of 0.

Adjust the quantity in stock (UnitsInStock) for the product by subtracting the quantity sold from inventory.

However, if there is not enough of a product in stock, then abort the stored procedure without making any changes to the database.

Print a message if the quantity in stock of a product drops below its Reorder Level as a result of the update. */

use AdventureWorks2022

-- Drop the existing procedure if it exists
IF OBJECT_ID('dbo.InsertOrderDetails', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.InsertOrderDetails;
END
GO

-- Create the new procedure
CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT,
    @Discount DECIMAL(5, 2) = 0
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CurrentUnitPrice MONEY;
    DECLARE @UnitsInStock INT;
    DECLARE @ReorderLevel INT;

    -- Get the current UnitPrice if not provided
    IF @UnitPrice IS NULL
    BEGIN
        SELECT @CurrentUnitPrice = UnitPrice
        FROM Product
        WHERE ProductID = @ProductID;
    END
    ELSE
    BEGIN
        SET @CurrentUnitPrice = @UnitPrice;
    END

    -- Get current stock and reorder level
    SELECT @UnitsInStock = UnitsInStock, @ReorderLevel = ReorderLevel
    FROM Product
    WHERE ProductID = @ProductID;

    -- Check if there is enough stock
    IF @UnitsInStock < @Quantity
    BEGIN
        PRINT 'Not enough stock available. Order aborted.';
        RETURN;
    END

    -- Insert the order detail
    INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount)
    VALUES (@OrderID, @ProductID, @CurrentUnitPrice, @Quantity, @Discount);

    -- Check if the row was inserted
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
        RETURN;
    END

    -- Adjust the stock quantity
    UPDATE Product
    SET UnitsInStock = UnitsInStock - @Quantity
    WHERE ProductID = @ProductID;

    -- Check the new stock level
    SELECT @UnitsInStock = UnitsInStock
    FROM Product
    WHERE ProductID = @ProductID;

    -- Print a message if the stock drops below the reorder level
    IF @UnitsInStock < @ReorderLevel
    BEGIN
        PRINT 'Warning: Stock level has dropped below the reorder level.';
    END
END;
GO

/*Create a procedure UpdateOrderDetails that takes OrderID, ProductID, UnitPrice,
Quantity, and discount, and updates these values for that ProductID in that Order.
All the parameters except the OrderID and ProductID should be optional so that
if the user wants to only update Quantity s/he should be able to do so without 
providing the rest of the values. You need to also make sure that if any of the
values are being passed in as NULL, then you want to retain the original value 
instead of overwriting it with NULL. To accomplish this, look for the
ISNULL() function in google or sql server books online. Adjust the
UnitsInStock value in products table accordingly.*/

USE AdventureWorks2022;
GO

-- Drop the existing procedure if it exists
IF OBJECT_ID('dbo.UpdateOrderDetails', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.UpdateOrderDetails;
END
GO

-- Create the new procedure
CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT = NULL,
    @Discount DECIMAL(5, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldQuantity INT;
    DECLARE @NewQuantity INT;
    DECLARE @UnitsInStock INT;

    -- Get the current values from Order Details
    SELECT @OldQuantity = Quantity
    FROM [Order Details]
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    -- Get the current UnitsInStock from Product
    SELECT @UnitsInStock = UnitsInStock
    FROM Product
    WHERE ProductID = @ProductID;

    -- Update the Order Details with the new values, retaining old values if new ones are NULL
    UPDATE [Order Details]
    SET
        UnitPrice = ISNULL(@UnitPrice, UnitPrice),
        Quantity = ISNULL(@Quantity, Quantity),
        Discount = ISNULL(@Discount, Discount)
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    -- Calculate the new quantity
    SELECT @NewQuantity = Quantity
    FROM [Order Details]
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    -- Adjust the UnitsInStock in Product table
    UPDATE Product
    SET UnitsInStock = UnitsInStock + (@OldQuantity - @NewQuantity)
    WHERE ProductID = @ProductID;

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to update the order. Please try again.';
        RETURN;
    END
END;
GO

/*Create a procedure GetOrderDetails that takes OrderID as input parameter and returns all the records for that OrderID. If no records are found in Order Details table, then it should print the line: "The OrderID XXXX does not exits", where XXX should be the OrderID entered by user and the procedure should RETURN

the value 1.*/

USE AdventureWorks2022;
GO

CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if there are any records for the given OrderID
    IF NOT EXISTS (SELECT 1 FROM [Order Details] WHERE OrderID = @OrderID)
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS NVARCHAR(10)) + ' does not exist';
        RETURN 1;
    END

    -- Return the records for the given OrderID
    SELECT *
    FROM [Order Details]
    WHERE OrderID = @OrderID;
END;
GO

/*Create a procedure DeleteOrderDetails that takes OrderID and ProductID and deletes
that from Order Details table. Your procedure should validate parameters. It should 
return an error code (-1) and print a message if the parameters are invalid. Parameters
are valid if the given order ID appears in the table and if the given product ID appears 
in that order.*/

USE AdventureWorks2022;
GO

CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the given OrderID exists
    IF NOT EXISTS (SELECT 1 FROM [Order Details] WHERE OrderID = @OrderID)
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS NVARCHAR(10)) + ' does not exist';
        RETURN -1;
    END

    -- Check if the given ProductID exists for the given OrderID
    IF NOT EXISTS (SELECT 1 FROM [Order Details] WHERE OrderID = @OrderID AND ProductID = @ProductID)
    BEGIN
        PRINT 'The ProductID ' + CAST(@ProductID AS NVARCHAR(10)) + ' does not exist for OrderID ' + CAST(@OrderID AS NVARCHAR(10));
        RETURN -1;
    END

    -- Delete the record from Order Details
    DELETE FROM [Order Details]
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to delete the order detail. Please try again.';
        RETURN -1;
    END
END;
GO

/*Create a function that takes an input parameter type datetime and returns the date in the format MM/DD/YYYY. 
For example if I pass in '2006-11-21 23:34:05.920', the output of the functions should be 11/21/2006*/

CREATE FUNCTION dbo.FormatDateToUS  (@date datetime)
RETURNS varchar(10)
AS
BEGIN
  DECLARE @formattedDate varchar(10)
  SET @formattedDate = CONVERT(varchar(10), @date, 101)
  RETURN @formattedDate
END;

/*Create a function that takes an input parameter type datetime and returns the date in the format YYYYMMDD*/

USE AdventureWorks2022;
GO

CREATE FUNCTION dbo.FormatDateYYYYMMDD (@InputDate DATETIME)
RETURNS VARCHAR(8)
AS
BEGIN
    RETURN CONVERT(VARCHAR(8), @InputDate, 112);
END;
GO

/*Views

Create a view vwCustomerOrders which returns CompanyName, OrderID, OrderDate, ProductID.ProductName, Quantity, UnitPrice, Quantity * od.UnitPrice*/

USE AdventureWorks2022;
GO

-- Then create the view
CREATE VIEW vwCustomerOrders
AS
SELECT 
    c.CustomerID,
    p.FirstName + ' ' + p.LastName AS CompanyName, -- Adjust if needed
    soh.SalesOrderID AS OrderID,
    soh.OrderDate,
    pr.ProductID,
    pr.Name AS ProductName,
    sod.OrderQty AS Quantity,
    sod.UnitPrice,
    sod.OrderQty * sod.UnitPrice AS TotalPrice
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN 
    Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Production.Product pr ON sod.ProductID = pr.ProductID;
GO

/*Create a copy of the above view and modify it so that it only returns the above information for orders that were placed yesterday*/

USE AdventureWorks2022;
GO

CREATE VIEW vwCustomerOrdersYesterday
AS
SELECT 
    c.CustomerID,
    p.FirstName + ' ' + p.LastName AS CompanyName, -- Adjust if needed
    soh.SalesOrderID AS OrderID,
    soh.OrderDate,
    pr.ProductID,
    pr.Name AS ProductName,
    sod.OrderQty AS Quantity,
    sod.UnitPrice,
    sod.OrderQty * sod.UnitPrice AS TotalPrice
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN 
    Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Production.Product pr ON sod.ProductID = pr.ProductID
WHERE 
    CAST(soh.OrderDate AS DATE) = CAST(GETDATE() - 1 AS DATE); -- Orders placed yesterday
GO

/*Use a CREATE VIEW statement to create a view called MyProducts. Your view should contain the ProductID, ProductName, QuantityPerUnit and
UnitPrice columns from the Products table. It should also contain the CompanyName column from the Suppliers table and the CategoryName column 
from the Categories table. Your view should only contain products that are not discontinued.*/

USE AdventureWorks2022;
GO

CREATE VIEW MyProducts
AS
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    p.ListPrice AS UnitPrice,
    v.Name AS CompanyName,
    c.Name AS CategoryName
FROM 
    Production.Product p
JOIN 
    Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
JOIN 
    Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
JOIN 
    Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN 
    Production.ProductCategory c ON ps.ProductCategoryID = c.ProductCategoryID
JOIN 
    Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID;
GO

/*Triggers

If someone cancels an order in northwind database, then you want to delete that order from the Orders table. But you will not be able
to delete that Order before deleting the records from Order Details table for that particular order due to referential integrity constraints.
Create an Instead of Delete trigger on Orders table so that if some one tries to delete an Order that trigger gets fired and that trigger
should first delete everything in order details table and then delete that order from the Orders table*/

USE AdventureWorks2022;
GO

CREATE TRIGGER trgInsteadOfDeleteOrder
ON Sales.SalesOrderHeader
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OrderID INT;

    -- Get the OrderID being deleted
    SELECT @OrderID = deleted.SalesOrderID FROM deleted;

    -- Delete records from OrderDetails table first
    DELETE FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID;

    -- Delete the order from Orders table
    DELETE FROM Sales.SalesOrderHeader WHERE SalesOrderID = @OrderID;
END;
GO

/*When an order is placed for X units of product Y, we must first check the Products table to ensure that there is sufficient stock to fill the order.
This trigger will operate on the Order Details table. If sufficient stock exists, then fill the order and decrement X units from the UnitsInStock
column in Products. If insufficient stock exists, then refuse the order (i.e. do not insert it) and notify the user that the order could not be
filled because of insufficient stock.*/

USE AdventureWorks2022;
GO

CREATE TRIGGER trgCheckStockAvailability
ON Sales.SalesOrderDetail
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProductID INT;
    DECLARE @Quantity INT;
    DECLARE @OrderID INT;

    -- Get the ProductID and Quantity being inserted
    SELECT @ProductID = ProductID, @Quantity = OrderQty, @OrderID = SalesOrderID FROM inserted;

    -- Check if there is sufficient stock
    IF EXISTS (
        SELECT 1 
        FROM Production.Product 
        WHERE ProductID = @ProductID AND SafetyStockLevel >= @Quantity
    )
    BEGIN
        -- Sufficient stock, fill the order
        INSERT INTO Sales.SalesOrderDetail (SalesOrderID, ProductID, UnitPrice, OrderQty, UnitPriceDiscount)
        SELECT SalesOrderID, ProductID, UnitPrice, OrderQty, UnitPriceDiscount FROM inserted;

        -- Decrement stock from Products table
        UPDATE Production.Product
        SET SafetyStockLevel = SafetyStockLevel - @Quantity
        WHERE ProductID = @ProductID;
    END
    ELSE
    BEGIN
        -- Insufficient stock, refuse the order
        RAISERROR ('Insufficient stock to fill the order.', 16, 1);
    END
END;
GO