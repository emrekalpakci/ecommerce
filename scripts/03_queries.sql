/* ============================================================
   E-Commerce Database - Example Queries
   Examples of JOIN, GROUP BY, aggregate functions, and subqueries.
   ============================================================ */

USE OnlineStore;
GO

-- 1) List every product with its category
SELECT p.ProductID, p.ProductName, c.CategoryName, p.Price, p.StockQuantity
FROM dbo.Products p
INNER JOIN dbo.Categories c ON p.CategoryID = c.CategoryID
ORDER BY c.CategoryName, p.ProductName;
GO

-- 2) Total amount for each order (with the customer name)
SELECT
    o.OrderID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    o.OrderDate,
    o.Status,
    SUM(oi.Quantity * oi.UnitPrice) AS OrderTotal
FROM dbo.Orders o
INNER JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
INNER JOIN dbo.OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY o.OrderID, c.FirstName, c.LastName, o.OrderDate, o.Status
ORDER BY OrderTotal DESC;
GO

-- 3) Best-selling products (by quantity, top 5)
SELECT TOP 5
    p.ProductName,
    SUM(oi.Quantity) AS TotalSold
FROM dbo.OrderItems oi
INNER JOIN dbo.Products p ON oi.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TotalSold DESC;
GO

-- 4) Total spend per customer (excluding cancelled orders)
SELECT
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    COUNT(DISTINCT o.OrderID) AS OrderCount,
    ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0) AS TotalSpent
FROM dbo.Customers c
LEFT JOIN dbo.Orders o
    ON c.CustomerID = o.CustomerID AND o.Status <> 'Cancelled'
LEFT JOIN dbo.OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY TotalSpent DESC;
GO

-- 5) Revenue by category
SELECT
    cat.CategoryName,
    SUM(oi.Quantity * oi.UnitPrice) AS Revenue
FROM dbo.OrderItems oi
INNER JOIN dbo.Products p ON oi.ProductID = p.ProductID
INNER JOIN dbo.Categories cat ON p.CategoryID = cat.CategoryID
INNER JOIN dbo.Orders o ON oi.OrderID = o.OrderID
WHERE o.Status <> 'Cancelled'
GROUP BY cat.CategoryName
ORDER BY Revenue DESC;
GO

-- 6) Low-stock products (fewer than 20)
SELECT ProductName, StockQuantity
FROM dbo.Products
WHERE StockQuantity < 20
ORDER BY StockQuantity ASC;
GO

-- 7) Customers who have never placed an order (subquery / NOT EXISTS)
SELECT FirstName, LastName, Email
FROM dbo.Customers c
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Orders o WHERE o.CustomerID = c.CustomerID
);
GO

-- 8) Orders above the average order total
SELECT OrderID, OrderTotal
FROM (
    SELECT o.OrderID, SUM(oi.Quantity * oi.UnitPrice) AS OrderTotal
    FROM dbo.Orders o
    INNER JOIN dbo.OrderItems oi ON o.OrderID = oi.OrderID
    GROUP BY o.OrderID
) AS OrderTotals
WHERE OrderTotal > (
    SELECT AVG(t.Total)
    FROM (
        SELECT SUM(oi.Quantity * oi.UnitPrice) AS Total
        FROM dbo.OrderItems oi
        GROUP BY oi.OrderID
    ) AS t
)
ORDER BY OrderTotal DESC;
GO
