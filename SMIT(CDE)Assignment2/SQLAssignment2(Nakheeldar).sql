-- Create Database
CREATE DATABASE BikeStores;
GO

-- Use Database
USE BikeStores;
GO

-- Create Schemas
CREATE SCHEMA sales;
GO
CREATE SCHEMA production;
GO

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
('John', 'Smith', '03009998888', 'john.smith@example.com', 'New York', 'NY');



CREATE TABLE production.categories (
    category_id INT PRIMARY KEY IDENTITY(1,1),
    category_name NVARCHAR(50)
);

INSERT INTO production.categories (category_name)
VALUES ('Mountain Bikes'), ('Road Bikes'), ('Hybrid Bikes');


CREATE TABLE production.brands (
    brand_id INT PRIMARY KEY IDENTITY(1,1),
    brand_name NVARCHAR(50)
);

INSERT INTO production.brands (brand_name)
VALUES ('Trek'), ('Giant'), ('Cannondale');







CREATE TABLE sales.staffs (
    staff_id INT PRIMARY KEY IDENTITY(1,1),
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    store_id INT,
    manager_id INT NULL,
    FOREIGN KEY (store_id) REFERENCES sales.stores(store_id)
);

INSERT INTO sales.staffs (first_name, last_name, store_id, manager_id)
VALUES ('Ahmed', 'Raza', 1, NULL),
       ('Bilal', 'Khan', 2, 1);


CREATE TABLE sales.orders (
    order_id INT PRIMARY KEY IDENTITY(1,1),
    customer_id INT,
    order_date DATE,
    store_id INT,
    staff_id INT,
    FOREIGN KEY (customer_id) REFERENCES sales.customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES sales.stores(store_id),
    FOREIGN KEY (staff_id) REFERENCES sales.staffs(staff_id)
);

INSERT INTO sales.orders (customer_id, order_date, store_id, staff_id)
VALUES
(1, '2021-01-10', 1, 1),
(2, '2021-02-05', 2, 2);


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
(2, 1, 3, 1, 600.00, 0.00);


-- Q1: Products with category
SELECT p.product_name, p.list_price, c.category_name
FROM production.products p
JOIN production.categories c ON p.category_id = c.category_id
ORDER BY p.product_name ASC;

-- Q2: Customers with orders
SELECT (c.first_name + ' ' + c.last_name) AS full_name, o.order_id, o.order_date
FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id
ORDER BY o.order_date DESC;

-- Q3: Products with category + brand
SELECT p.product_name, p.list_price, c.category_name, b.brand_name
FROM production.products p
JOIN production.categories c ON p.category_id = c.category_id
JOIN production.brands b ON p.brand_id = b.brand_id
ORDER BY b.brand_name ASC, p.product_name ASC;

-- Q4: Products with order items (include never ordered)
SELECT p.product_id, p.product_name, oi.order_id, oi.item_id
FROM production.products p
LEFT JOIN sales.order_items oi ON p.product_id = oi.product_id
ORDER BY oi.order_id ASC;

-- Q5: Products never ordered
SELECT p.product_id, p.product_name
FROM production.products p
LEFT JOIN sales.order_items oi ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;

-- Q6: Stores with orders
SELECT s.store_name, s.store_id, o.order_id, o.order_date
FROM sales.stores s
LEFT JOIN sales.orders o ON s.store_id = o.store_id
ORDER BY s.store_id ASC;

-- Q7: Staff with manager
SELECT (s.first_name + ' ' + s.last_name) AS staff_name,
       (m.first_name + ' ' + m.last_name) AS manager_name
FROM sales.staffs s
JOIN sales.staffs m ON s.manager_id = m.staff_id;

-- Q8: All combinations of store + brand
SELECT s.store_name, b.brand_name
FROM sales.stores s
CROSS JOIN production.brands b;


-- Q9: Customer orders with product details
SELECT (c.first_name + ' ' + c.last_name) AS full_name,
       o.order_id, o.order_date, p.product_name, p.list_price
FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
JOIN production.products p ON oi.product_id = p.product_id
ORDER BY o.order_date ASC, full_name ASC;
