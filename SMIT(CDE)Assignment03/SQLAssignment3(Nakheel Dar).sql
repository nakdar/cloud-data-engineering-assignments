-- ============================================================
-- SECTION A — GROUP BY & AGGREGATE FUNCTIONS
-- ============================================================

-- Q1: Orders per customer
SELECT customer_id, COUNT(order_id) AS order_count
FROM sales.orders
GROUP BY customer_id
ORDER BY order_count DESC;   -- sabse zyada orders pehle

-- Q2: Orders per store
SELECT store_id, COUNT(order_id) AS total_orders
FROM sales.orders
GROUP BY store_id;

-- Q3: Net revenue per order
SELECT order_id,
       SUM(quantity * list_price * (1 - discount)) AS net_revenue
FROM sales.order_items
GROUP BY order_id
ORDER BY net_revenue DESC;

-- Q4: Average product price per category
SELECT category_id,
       ROUND(AVG(list_price), 2) AS avg_price
FROM production.products
GROUP BY category_id;

-- Q5: Orders per year
SELECT YEAR(order_date) AS order_year,
       COUNT(order_id) AS total_orders
FROM sales.orders
GROUP BY YEAR(order_date)
ORDER BY order_year ASC;


-- ============================================================
-- SECTION B — HAVING CLAUSE
-- ============================================================

-- Q6: Customers with more than 5 orders
SELECT customer_id, COUNT(order_id) AS order_count
FROM sales.orders
GROUP BY customer_id
HAVING COUNT(order_id) > 5;

-- Q7: Categories with avg price > 1500
SELECT category_id, ROUND(AVG(list_price), 2) AS avg_price
FROM production.products
GROUP BY category_id
HAVING AVG(list_price) > 1500;

-- Q8: Customers with at least 2 orders in 2017
SELECT customer_id, YEAR(order_date) AS order_year, COUNT(order_id) AS order_count
FROM sales.orders
WHERE YEAR(order_date) = 2017
GROUP BY customer_id, YEAR(order_date)
HAVING COUNT(order_id) >= 2;


-- ============================================================
-- SECTION C — SUBQUERIES
-- ============================================================

-- Q9: Orders by customers in Houston
SELECT *
FROM sales.orders
WHERE customer_id IN (
    SELECT customer_id
    FROM sales.customers
    WHERE city = 'Houston'
);

-- Q10: Products with price > average price
SELECT product_name, list_price
FROM production.products
WHERE list_price > (
    SELECT AVG(list_price)
    FROM production.products
);

-- Q11: Products in Mountain or Road Bikes
SELECT product_name, list_price
FROM production.products
WHERE category_id IN (
    SELECT category_id
    FROM production.categories
    WHERE category_name IN ('Mountain Bikes', 'Road Bikes')
);

-- Q12: Customers who never placed an order
SELECT customer_id, first_name, last_name
FROM sales.customers
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM sales.orders
);


-- ============================================================
-- SECTION D — JOINs WITH GROUP BY
-- ============================================================

-- Q13: Orders per city
SELECT c.city, COUNT(o.order_id) AS total_orders
FROM sales.orders o
JOIN sales.customers c ON o.customer_id = c.customer_id
GROUP BY c.city
ORDER BY total_orders DESC;

-- Q14: Orders per staff
SELECT (s.first_name + ' ' + s.last_name) AS staff_name,
       COUNT(o.order_id) AS order_count
FROM sales.orders o
JOIN sales.staffs s ON o.staff_id = s.staff_id
GROUP BY s.first_name, s.last_name
ORDER BY order_count DESC;

-- Q15: Customers who spent more than 10,000
SELECT (c.first_name + ' ' + c.last_name) AS customer_name,
       SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY c.first_name, c.last_name
HAVING SUM(oi.quantity * oi.list_price * (1 - oi.discount)) > 10000
ORDER BY total_spent DESC;
