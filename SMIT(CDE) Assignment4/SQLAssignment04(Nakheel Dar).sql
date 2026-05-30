-- Step 1: Fresh Database & Schemas
DROP DATABASE IF EXISTS BikeStores;
GO
CREATE DATABASE BikeStores;
GO
USE BikeStores;
GO
CREATE SCHEMA sales;
GO
CREATE SCHEMA production;
GO

-- Step 2: Customers
CREATE TABLE sales.customers (
    customer_id INT PRIMARY KEY IDENTITY(1,1),
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    phone NVARCHAR(25),
    email NVARCHAR(100),
    city NVARCHAR(50),
    state NVARCHAR(10)
);

INSERT INTO sales.customers (first_name, last_name, phone, email, city, state)
VALUES
('Ali', 'Khan', '03001234567', 'ali.khan@example.com', 'Los Angeles', 'CA'),
('Sara', 'Ahmed', '03007654321', 'sara.ahmed@example.com', 'San Diego', 'CA'),
('John', 'Smith', '03009998888', 'john.smith@example.com', 'New York', 'NY'),
('Hina', 'Raza', NULL, 'hina.raza@example.com', 'Houston', 'TX');

-- Step 3: Categories
CREATE TABLE production.categories (
    category_id INT PRIMARY KEY IDENTITY(1,1),
    category_name NVARCHAR(50)
);
INSERT INTO production.categories (category_name)
VALUES ('Mountain Bikes'), ('Road Bikes'), ('Hybrid Bikes');

-- Step 4: Brands
CREATE TABLE production.brands (
    brand_id INT PRIMARY KEY IDENTITY(1,1),
    brand_name NVARCHAR(50)
);
INSERT INTO production.brands (brand_name)
VALUES ('Trek'), ('Giant'), ('Cannondale');

-- Step 5: Products
CREATE TABLE production.products (
    product_id INT PRIMARY KEY IDENTITY(1,1),
    product_name NVARCHAR(100),
    brand_id INT,
    category_id INT,
    model_year INT,
    list_price DECIMAL(10,2),
    FOREIGN KEY (brand_id) REFERENCES production.brands(brand_id),
    FOREIGN KEY (category_id) REFERENCES production.categories(category_id)
);
INSERT INTO production.products (product_name, brand_id, category_id, model_year, list_price)
VALUES
('Mountain Bike X1', 1, 1, 2019, 1200.00),
('Road Bike Z2', 2, 2, 2020, 800.00),
('Hybrid Bike H3', 3, 3, 2021, 600.00);

-- Step 6: Stores
CREATE TABLE sales.stores (
    store_id INT PRIMARY KEY IDENTITY(1,1),
    store_name NVARCHAR(100),
    state NVARCHAR(10)
);
INSERT INTO sales.stores (store_name, state)
VALUES ('Main Store', 'CA'), ('East Store', 'NY');

-- Step 7: Staffs
CREATE TABLE sales.staffs (
    staff_id INT PRIMARY KEY IDENTITY(1,1),
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    email NVARCHAR(100),
    store_id INT,
    manager_id INT NULL,
    FOREIGN KEY (store_id) REFERENCES sales.stores(store_id)
);
INSERT INTO sales.staffs (first_name, last_name, email, store_id, manager_id)
VALUES ('Ahmed', 'Raza', 'ahmed@bikestores.com', 1, NULL),
       ('Bilal', 'Khan', 'bilal@bikestores.com', 2, 1);

-- Step 8: Orders
CREATE TABLE sales.orders (
    order_id INT PRIMARY KEY IDENTITY(1,1),
    customer_id INT,
    order_status NVARCHAR(20),
    order_date DATE,
    shipped_date DATE,
    store_id INT,
    staff_id INT,
    FOREIGN KEY (customer_id) REFERENCES sales.customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES sales.stores(store_id),
    FOREIGN KEY (staff_id) REFERENCES sales.staffs(staff_id)
);
INSERT INTO sales.orders (customer_id, order_status, order_date, shipped_date, store_id, staff_id)
VALUES
(1, 'Shipped', '2018-01-10', '2018-01-12', 1, 1),
(2, 'Pending', '2019-02-05', NULL, 2, 2),
(3, 'Processing', '2017-03-15', '2017-03-18', 1, 1);

-- Step 9: Order Items
CREATE TABLE sales.order_items (
    order_id INT,
    item_id INT,
    product_id INT,
    quantity INT,
    list_price DECIMAL(10,2),
    discount DECIMAL(4,2),
    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id) REFERENCES sales.orders(order_id),
    FOREIGN KEY (product_id) REFERENCES production.products(product_id)
);
INSERT INTO sales.order_items (order_id, item_id, product_id, quantity, list_price, discount)
VALUES
(1, 1, 1, 2, 1200.00, 0.00),
(1, 2, 2, 1, 800.00, 0.05),
(2, 1, 3, 1, 600.00, 0.00),
(3, 1, 1, 3, 1200.00, 0.10);

-- Step 10: Stocks (for CASE Q10 in Assignment 04)
CREATE TABLE production.stocks (
    store_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (store_id) REFERENCES sales.stores(store_id),
    FOREIGN KEY (product_id) REFERENCES production.products(product_id)
);
INSERT INTO production.stocks (store_id, product_id, quantity)
VALUES (1, 1, 0), (1, 2, 8), (2, 3, 55);

-- Step 11: Loyalty Cards (Assignment 04 constraints)
CREATE TABLE sales.loyalty_cards (
    card_number   INT PRIMARY KEY,
    customer_id   INT NOT NULL,
    points        INT CHECK (points >= 0),
    tier          VARCHAR(10) CHECK (tier IN ('Bronze','Silver','Gold')),
    join_date     DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES sales.customers(customer_id) ON DELETE CASCADE
);
INSERT INTO sales.loyalty_cards VALUES (1001, 1, 500, 'Gold', '2024-01-15');
INSERT INTO sales.loyalty_cards VALUES (1002, 2, 150, 'Silver', '2024-03-22');
INSERT INTO sales.loyalty_cards VALUES (1003, 3, 0, 'Bronze', '2024-06-01');

-- Step 12: Test Tables (Assignment 05 duplicates)
CREATE TABLE test_customers (
    customer_id  INT,
    first_name   VARCHAR(50),
    last_name    VARCHAR(50),
    phone        VARCHAR(20),
    city         VARCHAR(50)
);
INSERT INTO test_customers VALUES
(1, 'Ali', 'Khan', '0300-1111111', 'Karachi'),
(2, 'Sara', 'Ahmed', '0321-2222222', 'Lahore'),
(3, 'Ali', 'Khan', '0300-1111111', 'Karachi'),
(4, 'Usman', 'Malik', '0333-3333333', 'Islamabad'),
(5, 'Sara', 'Ahmed', '0321-2222222', 'Lahore'),
(6, 'Sara', 'Ahmed', '0321-2222222', 'Lahore'),
(7, 'Hina', 'Raza', '0312-4444444', 'Peshawar');


-- ============================================================
-- ASSIGNMENT 04 — SET OPERATORS, CTEs, CONSTRAINTS & CASES
-- Database  : BikeStores
-- ============================================================

-- ============================================================
-- SECTION A — SET OPERATORS
-- ============================================================

-- Q1: Unified contact list (staff + customers, no duplicates)
SELECT (first_name + ' ' + last_name) AS full_name, email
FROM sales.customers
UNION
SELECT (first_name + ' ' + last_name) AS full_name, email
FROM sales.staffs;

-- Q2: States with both stores and customers
SELECT state
FROM sales.customers
INTERSECT
SELECT state
FROM sales.stores;

-- Q3: Stores with no orders in 2018
SELECT store_id
FROM sales.stores
EXCEPT
SELECT store_id
FROM sales.orders
WHERE YEAR(order_date) = 2018;


-- ============================================================
-- SECTION B — CTEs
-- ============================================================

-- Q4: Products overpriced compared to category average
WITH CategoryAvg AS (
    SELECT category_id, AVG(list_price) AS avg_price
    FROM production.products
    GROUP BY category_id
)
SELECT p.category_id, p.product_name, p.list_price, ca.avg_price
FROM production.products p
JOIN CategoryAvg ca ON p.category_id = ca.category_id
WHERE p.list_price > ca.avg_price;

-- Q5: Staff with order count > average
WITH StaffOrders AS (
    SELECT staff_id, COUNT(order_id) AS order_count
    FROM sales.orders
    GROUP BY staff_id
),
AvgOrders AS (
    SELECT AVG(order_count) AS avg_count FROM StaffOrders
)
SELECT s.staff_id, s.order_count
FROM StaffOrders s, AvgOrders a
WHERE s.order_count > a.avg_count;

-- Q6: Store yearly revenue > 1,000,000
WITH StoreRevenue AS (
    SELECT o.store_id, YEAR(o.order_date) AS order_year,
           SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY o.store_id, YEAR(o.order_date)
)
SELECT store_id, order_year, total_revenue
FROM StoreRevenue
WHERE total_revenue > 1000000;


-- ============================================================
-- SECTION C — CONSTRAINTS
-- ============================================================

-- Q7: Loyalty cards with constraints
CREATE TABLE sales.loyalty_cards (
    card_number   INT PRIMARY KEY,
    customer_id   INT NOT NULL,
    points        INT CHECK (points >= 0),
    tier          VARCHAR(10) CHECK (tier IN ('Bronze','Silver','Gold')),
    join_date     DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES sales.customers(customer_id) ON DELETE CASCADE
);

-- Test inserts (good data)
INSERT INTO sales.loyalty_cards VALUES (1001, 1, 500, 'Gold', '2024-01-15');
INSERT INTO sales.loyalty_cards VALUES (1002, 2, 150, 'Silver', '2024-03-22');
INSERT INTO sales.loyalty_cards VALUES (1003, 3, 0, 'Bronze', '2024-06-01');

-- Bad data (should fail)
-- INSERT INTO sales.loyalty_cards VALUES (1001, 4, 100, 'Gold', '2024-07-01'); -- duplicate card_number
-- INSERT INTO sales.loyalty_cards VALUES (1004, 1, -50, 'Silver', '2024-08-01'); -- negative points
-- INSERT INTO sales.loyalty_cards VALUES (1005, 5, 200, 'Diamond','2024-09-01'); -- invalid tier


-- Q8: Prevent shipped_date < order_date
ALTER TABLE sales.orders
ADD CONSTRAINT chk_dates CHECK (shipped_date IS NULL OR shipped_date >= order_date);

-- Test
-- INSERT INTO sales.orders (customer_id, order_status, order_date, shipped_date, store_id, staff_id)
-- VALUES (4, 'Shipped', '2024-04-10', '2024-04-08', 1, 1); -- FAIL
-- INSERT INTO sales.orders (customer_id, order_status, order_date, shipped_date, store_id, staff_id)
-- VALUES (4, 'Shipped', '2024-04-10', '2024-04-15', 1, 1); -- PASS


-- ============================================================
-- SECTION D — CASE EXPRESSIONS
-- ============================================================

-- Q9: Shipping speed classification
SELECT order_id, order_date, shipped_date,
       CASE
           WHEN shipped_date IS NULL THEN 'Pending'
           WHEN DATEDIFF(DAY, order_date, shipped_date) <= 2 THEN 'Fast'
           WHEN DATEDIFF(DAY, order_date, shipped_date) BETWEEN 3 AND 5 THEN 'Normal'
           WHEN DATEDIFF(DAY, order_date, shipped_date) > 5 THEN 'Delayed'
       END AS shipping_speed
FROM sales.orders;

-- Q10: Stock levels per store
SELECT store_id, product_id, quantity,
       CASE
           WHEN quantity = 0 THEN 'Out of Stock'
           WHEN quantity BETWEEN 1 AND 10 THEN 'Low Stock'
           WHEN quantity BETWEEN 11 AND 50 THEN 'Sufficient'
           ELSE 'Well Stocked'
       END AS stock_status
FROM production.stocks
ORDER BY store_id ASC, quantity ASC;
