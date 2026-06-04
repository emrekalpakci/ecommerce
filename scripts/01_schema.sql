/* ============================================================
   E-Commerce Database - Schema
   Microsoft SQL Server (T-SQL)
   ------------------------------------------------------------
   Tables: Categories, Products, Customers, Orders, OrderItems
   ============================================================ */

-- Create the database (if it does not exist)
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'OnlineStore')
BEGIN
    CREATE DATABASE OnlineStore;
END
GO

USE OnlineStore;
GO

-- Drop existing tables first so the script is re-runnable
-- (mind the dependency order: child tables first)
IF OBJECT_ID('dbo.OrderItems', 'U') IS NOT NULL DROP TABLE dbo.OrderItems;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
GO

-- Categories
CREATE TABLE dbo.Categories (
    CategoryID    INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName  NVARCHAR(100) NOT NULL UNIQUE
);
GO

-- Products
CREATE TABLE dbo.Products (
    ProductID      INT IDENTITY(1,1) PRIMARY KEY,
    ProductName    NVARCHAR(150) NOT NULL,
    CategoryID     INT NOT NULL,
    Price          DECIMAL(10, 2) NOT NULL CONSTRAINT CK_Products_Price CHECK (Price >= 0),
    StockQuantity  INT NOT NULL DEFAULT 0 CONSTRAINT CK_Products_Stock CHECK (StockQuantity >= 0),
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID)
        REFERENCES dbo.Categories (CategoryID)
);
GO

-- Customers
CREATE TABLE dbo.Customers (
    CustomerID     INT IDENTITY(1,1) PRIMARY KEY,
    FirstName      NVARCHAR(50) NOT NULL,
    LastName       NVARCHAR(50) NOT NULL,
    Email          NVARCHAR(150) NOT NULL UNIQUE,
    City           NVARCHAR(80) NULL,
    RegisteredDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE)
);
GO

-- Orders
CREATE TABLE dbo.Orders (
    OrderID     INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID  INT NOT NULL,
    OrderDate   DATETIME NOT NULL DEFAULT GETDATE(),
    Status      NVARCHAR(20) NOT NULL DEFAULT 'Pending'
        CONSTRAINT CK_Orders_Status CHECK (Status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled')),
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customers (CustomerID)
);
GO

-- Order items (many-to-many relationship between Orders and Products)
CREATE TABLE dbo.OrderItems (
    OrderItemID  INT IDENTITY(1,1) PRIMARY KEY,
    OrderID      INT NOT NULL,
    ProductID    INT NOT NULL,
    Quantity     INT NOT NULL CONSTRAINT CK_OrderItems_Qty CHECK (Quantity > 0),
    UnitPrice    DECIMAL(10, 2) NOT NULL,  -- Price at the time of the order
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderID)
        REFERENCES dbo.Orders (OrderID),
    CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductID)
        REFERENCES dbo.Products (ProductID)
);
GO

-- Indexes on frequently queried columns for performance
CREATE INDEX IX_Products_CategoryID ON dbo.Products (CategoryID);
CREATE INDEX IX_Orders_CustomerID ON dbo.Orders (CustomerID);
CREATE INDEX IX_OrderItems_OrderID ON dbo.OrderItems (OrderID);
CREATE INDEX IX_OrderItems_ProductID ON dbo.OrderItems (ProductID);
GO

PRINT 'Schema created successfully.';
GO
