/* ============================================================
   E-Commerce Database - Sample Data
   Run after 01_schema.sql.
   ============================================================ */

USE OnlineStore;
GO

-- Categories
INSERT INTO dbo.Categories (CategoryName) VALUES
    (N'Electronics'),
    (N'Books'),
    (N'Clothing'),
    (N'Home & Living'),
    (N'Sports');
GO

-- Products (CategoryID values 1..5 follow the order above)
INSERT INTO dbo.Products (ProductName, CategoryID, Price, StockQuantity) VALUES
    (N'Wireless Headphones',            1, 79.90,  50),
    (N'Mechanical Keyboard',            1, 124.90, 30),
    (N'USB-C Charging Cable',           1, 8.99,   200),
    (N'Data Structures and Algorithms', 2, 32.00,  40),
    (N'Clean Code',                     2, 24.50,  25),
    (N'Cotton T-Shirt',                 3, 15.99,  100),
    (N'Running Shoes',                  5, 89.00,  20),
    (N'Yoga Mat',                       5, 34.90,  35),
    (N'Desk Lamp',                      4, 45.90,  15),
    (N'Ceramic Mug',                    4, 7.99,   80);
GO

-- Customers
INSERT INTO dbo.Customers (FirstName, LastName, Email, City, RegisteredDate) VALUES
    (N'James',   N'Smith',    N'james.smith@example.com',    N'London',     '2025-11-10'),
    (N'Emma',    N'Johnson',  N'emma.johnson@example.com',   N'New York',   '2025-12-01'),
    (N'Liam',    N'Williams', N'liam.williams@example.com',  N'Toronto',    '2026-01-15'),
    (N'Olivia',  N'Brown',    N'olivia.brown@example.com',   N'Manchester', '2026-02-20'),
    (N'Noah',    N'Davis',    N'noah.davis@example.com',     N'Sydney',     '2026-03-05');
GO

-- Orders
INSERT INTO dbo.Orders (CustomerID, OrderDate, Status) VALUES
    (1, '2026-03-10', 'Delivered'),
    (2, '2026-03-12', 'Shipped'),
    (1, '2026-04-01', 'Pending'),
    (3, '2026-04-15', 'Delivered'),
    (4, '2026-05-02', 'Cancelled'),
    (5, '2026-05-20', 'Pending');
GO

-- Order items
-- UnitPrice represents the price at the time of the order (copied from the product price).
INSERT INTO dbo.OrderItems (OrderID, ProductID, Quantity, UnitPrice) VALUES
    (1, 1, 1, 79.90),
    (1, 3, 2, 8.99),
    (2, 4, 1, 32.00),
    (2, 5, 1, 24.50),
    (3, 7, 1, 89.00),
    (4, 2, 1, 124.90),
    (4, 3, 3, 8.99),
    (4, 10, 4, 7.99),
    (5, 6, 2, 15.99),
    (6, 8, 1, 34.90),
    (6, 9, 1, 45.90);
GO

PRINT 'Sample data inserted.';
GO
