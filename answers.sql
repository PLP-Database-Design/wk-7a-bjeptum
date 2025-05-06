-- Transform to 1NF 

-- Create the original ProductDetail table
CREATE TEMPORARY TABLE ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(100),
    Products VARCHAR(255)
);

-- Insert sample data
INSERT INTO ProductDetail (OrderID, CustomerName, Products) VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');

-- Use a recursive CTE to split the Products into individual rows
WITH RECURSIVE ProductSplit AS (
    SELECT 
        OrderID,
        CustomerName,
        TRIM(SUBSTRING_INDEX(Products, ',', 1)) AS Product,
        SUBSTRING(Products, LENGTH(SUBSTRING_INDEX(Products, ',', 1)) + 2) AS Remaining
    FROM ProductDetail
    UNION ALL
    SELECT
        OrderID,
        CustomerName,
        TRIM(SUBSTRING_INDEX(Remaining, ',', 1)),
        SUBSTRING(Remaining, LENGTH(SUBSTRING_INDEX(Remaining, ',', 1)) + 2)
    FROM ProductSplit
    WHERE Remaining <> ''
)
SELECT OrderID, CustomerName, Product
FROM ProductSplit
ORDER BY OrderID;

-- Transform to 2NF
-- Create the original OrderDetails table
CREATE TEMPORARY TABLE OrderDetails (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(50),
    Quantity INT
);

-- Insert sample data
INSERT INTO OrderDetails (OrderID, CustomerName, Product, Quantity) VALUES
(101, 'John Doe', 'Laptop', 2),
(101, 'John Doe', 'Mouse', 1),
(102, 'Jane Smith', 'Tablet', 3),
(102, 'Jane Smith', 'Keyboard', 1),
(102, 'Jane Smith', 'Mouse', 2),
(103, 'Emily Clark', 'Phone', 1);

-- Create a new Customers table to remove partial dependency
CREATE TEMPORARY TABLE Customers (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

INSERT INTO Customers (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- Create a separate OrderItems table
CREATE TEMPORARY TABLE OrderItems (
    OrderID INT,
    Product VARCHAR(50),
    Quantity INT
);

INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;
