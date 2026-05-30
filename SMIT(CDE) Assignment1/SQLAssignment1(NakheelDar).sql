-- Step 1: Create Database
CREATE DATABASE BikeStores1;
GO

-- Step 2: Use Database
USE BikeStores;
GO

-- Step 3: Create Schemas (run separately)
CREATE SCHEMA sales1;
GO

CREATE SCHEMA production;
GO

-- Step 4: Create Customers Table
CREATE TABLE sales.customers (
    customer_id INT PRIMARY KEY IDENTITY(1,1),
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    phone NVARCHAR(25),
    email NVARCHAR(100),
    street NVARCHAR(100),
    city NVARCHAR(50),
    state NVARCHAR(10),
    zip_code NVARCHAR(10)
);

-- Insert Sample Customers
INSERT INTO sales.customers (first_name, last_name, phone, email, street, city, state, zip_code)
VALUES
('Ali', 'Khan', '03001234567', 'ali.khan@example.com', 'Street 1', 'Los Angeles', 'CA', '90001'),
('Sara', 'Ahmed', NULL, 'sara.ahmed@example.com', 'Street 2', 'San Diego', 'CA', '92093'),
('John', 'Smith', '03007654321', 'john.smith@example.com', 'Street 3', 'New York', 'NY', '10001');


-- Step 5: Create Products Table
CREATE TABLE production.products (
    product_id INT PRIMARY KEY IDENTITY(1,1),
    product_name NVARCHAR(100),
    brand_id INT,
    category_id INT,
    model_year INT,
    list_price DECIMAL(10,2)
);

-- Insert Sample Products
INSERT INTO production.products (product_name, brand_id, category_id, model_year, list_price)
VALUES
('Mountain Bike X1', 1, 1, 2019, 1200.00),
('Road Bike Z2', 2, 2, 2020, 800.00),
('Hybrid Bike H3', 3, 3, 2021, 600.00),
('Kids Bike K4', 4, 4, 2020, 300.00),
('Electric Bike E5', 5, 5, 2019, 1500.00),
('Folding Bike F6', 6, 6, 2020, 450.00),
('Touring Bike T7', 7, 7, 2021, 950.00),
('BMX Bike B8', 8, 8, 2019, 500.00),
('Gravel Bike G9', 9, 9, 2020, 1100.00),
('City Bike C10', 10, 10, 2021, 700.00);



USE BikeStores;
GO

-- Insert Customers
INSERT INTO sales.customers (first_name, last_name, phone, email, street, city, state, zip_code)
VALUES
('Ali', 'Khan', '03001234567', 'ali.khan@example.com', 'Street 1', 'Los Angeles', 'CA', '90001'),
('Sara', 'Ahmed', NULL, 'sara.ahmed@example.com', 'Street 2', 'San Diego', 'CA', '92093'),
('John', 'Smith', '03007654321', 'john.smith@example.com', 'Street 3', 'New York', 'NY', '10001');

-- Insert Products
INSERT INTO production.products (product_name, brand_id, category_id, model_year, list_price)
VALUES
('Mountain Bike X1', 1, 1, 2019, 1200.00),
('Road Bike Z2', 2, 2, 2020, 800.00),
('Hybrid Bike H3', 3, 3, 2021, 600.00),
('Kids Bike K4', 4, 4, 2020, 300.00),
('Electric Bike E5', 5, 5, 2019, 1500.00),
('Folding Bike F6', 6, 6, 2020, 450.00),
('Touring Bike T7', 7, 7, 2021, 950.00),
('BMX Bike B8', 8, 8, 2019, 500.00),
('Gravel Bike G9', 9, 9, 2020, 1100.00),
('City Bike C10', 10, 10, 2021, 700.00);

-- Question 1 — SELECT & WHERE


SELECT first_name, last_name, city, phone
FROM sales.customers
WHERE state = 'CA'         -- yahan filter lagaya hai state CA
  AND phone IS NOT NULL;   -- aur phone record hona chahiye



-- Question 2 — ORDER BY (Multiple Columns)

SELECT product_id, product_name, model_year, list_price
FROM production.products
ORDER BY model_year DESC,   -- pehle latest year
         list_price ASC;    -- usi year ke andar cheapest pehle



-- Question 3 — TOP N & TOP PERCENT
-- Part a: Top 5 expensive products
-- Part b: Top 5% cheapest products


-- Part a:
SELECT TOP 5 product_name, list_price
FROM production.products
ORDER BY list_price DESC;   -- sabse mehngi products

-- Part b:
SELECT TOP 5 PERCENT *
FROM production.products
ORDER BY list_price ASC;    -- sabse sasti 5% products



-- Question 4 — OFFSET & FETCH (Pagination)


-- Page 1 (rows 1–10):
SELECT product_id, product_name, list_price
FROM production.products
ORDER BY list_price DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- Page 2 (rows 11–20):
SELECT product_id, product_name, list_price
FROM production.products
ORDER BY list_price DESC
OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;

-- Page 3 (rows 21–30):
SELECT product_id, product_name, list_price
FROM production.products
ORDER BY list_price DESC
OFFSET 20 ROWS FETCH NEXT 10 ROWS ONLY;



-- Question 5 — DISTINCT


-- Part a: Unique states
SELECT DISTINCT state
FROM sales.customers
ORDER BY state ASC;

-- Part b: Unique state + city combos
SELECT DISTINCT state, city
FROM sales.customers
ORDER BY state ASC, city ASC;

-- Part c: Count distinct model years
SELECT COUNT(DISTINCT model_year) AS unique_years
FROM production.products;



-- Question 6 — Logical Operators (AND / OR)

SELECT product_id, product_name, brand_id, category_id, list_price
FROM production.products
WHERE list_price BETWEEN 500 AND 1500   -- price range filter
  AND (model_year = 2019 OR model_year = 2020) -- year condition
ORDER BY list_price ASC;                -- cheapest pehle
