/* ============================================================
   E-Commerce Database - View, Stored Procedure, and Trigger
   ============================================================ */

USE OnlineStore;
GO

/* ---------- VIEW: Order summary ---------- */
IF OBJECT_ID('dbo.vw_OrderSummary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_OrderSummary;
GO

CREATE VIEW dbo.vw_OrderSummary AS
SELECT
    o.OrderID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    o.OrderDate,
    o.Status,
    COUNT(oi.OrderItemID) AS ItemCount,
    SUM(oi.Quantity * oi.UnitPrice) AS OrderTotal
FROM dbo.Orders o
INNER JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
INNER JOIN dbo.OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY o.OrderID, c.FirstName, c.LastName, o.OrderDate, o.Status;
GO

-- Usage: SELECT * FROM dbo.vw_OrderSummary ORDER BY OrderTotal DESC;


/* ---------- STORED PROCEDURE: Get a customer's orders ---------- */
IF OBJECT_ID('dbo.usp_GetCustomerOrders', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetCustomerOrders;
GO

CREATE PROCEDURE dbo.usp_GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        o.OrderID,
        o.OrderDate,
        o.Status,
        SUM(oi.Quantity * oi.UnitPrice) AS OrderTotal
    FROM dbo.Orders o
    INNER JOIN dbo.OrderItems oi ON o.OrderID = oi.OrderID
    WHERE o.CustomerID = @CustomerID
    GROUP BY o.OrderID, o.OrderDate, o.Status
    ORDER BY o.OrderDate DESC;
END;
GO

-- Usage: EXEC dbo.usp_GetCustomerOrders @CustomerID = 1;


/* ---------- STORED PROCEDURE: Add a new order item ---------- */
-- Performs a stock check and takes the price from the product's current price.
IF OBJECT_ID('dbo.usp_AddOrderItem', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_AddOrderItem;
GO

CREATE PROCEDURE dbo.usp_AddOrderItem
    @OrderID   INT,
    @ProductID INT,
    @Quantity  INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Stock INT, @Price DECIMAL(10, 2);

    SELECT @Stock = StockQuantity, @Price = Price
    FROM dbo.Products
    WHERE ProductID = @ProductID;

    IF @Stock IS NULL
    BEGIN
        RAISERROR('Product not found.', 16, 1);
        RETURN;
    END

    IF @Stock < @Quantity
    BEGIN
        RAISERROR('Insufficient stock.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.OrderItems (OrderID, ProductID, Quantity, UnitPrice)
    VALUES (@OrderID, @ProductID, @Quantity, @Price);
END;
GO

-- Usage: EXEC dbo.usp_AddOrderItem @OrderID = 1, @ProductID = 2, @Quantity = 1;


/* ---------- TRIGGER: Reduce stock when an order item is added ---------- */
IF OBJECT_ID('dbo.trg_OrderItems_UpdateStock', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_OrderItems_UpdateStock;
GO

CREATE TRIGGER dbo.trg_OrderItems_UpdateStock
ON dbo.OrderItems
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Bulk update via INSERTED since multiple rows may be inserted at once
    UPDATE p
    SET p.StockQuantity = p.StockQuantity - i.Quantity
    FROM dbo.Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID;
END;
GO

PRINT 'View, stored procedure, and trigger created.';
GO
