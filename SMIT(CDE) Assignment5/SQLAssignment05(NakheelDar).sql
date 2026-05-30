

-- ============================================================
-- ASSIGNMENT 05 — INDEXES, VIEWS & WINDOW FUNCTIONS
-- Database  : BikeStores
-- ============================================================

-- ============================================================
-- SECTION A — INDEXES
-- ============================================================

-- Q1: Index on brand_id for faster product search
CREATE NONCLUSTERED INDEX idx_products_brand
ON production.products (brand_id);

-- Test query
SELECT product_id, product_name, list_price
FROM production.products
WHERE brand_id = 3;


-- Q2: Index on order_date for faster date range queries
CREATE NONCLUSTERED INDEX idx_orders_date
ON sales.orders (order_date);

-- Test query
SELECT order_id, customer_id, order_date
FROM sales.orders
WHERE order_date BETWEEN '2018-01-01' AND '2018-06-30';


-- ============================================================
-- SECTION B — VIEWS
-- ============================================================

-- Q3: View for pending/processing orders
GO
CREATE VIEW vw_pending_orders AS
SELECT o.order_id,
       (c.first_name + ' ' + c.last_name) AS full_name,
       c.phone, c.email,
       o.order_date,
       CASE o.order_status
           WHEN 'Pending' THEN 'Pending'
           WHEN 'Processing' THEN 'Processing'
           ELSE 'Other'
       END AS order_status_label
FROM sales.orders o
JOIN sales.customers c ON o.customer_id = c.customer_id
WHERE o.order_status IN ('Pending','Processing');
GO

-- Query the view
SELECT * FROM vw_pending_orders;


-- Q4: View for stock monitoring
GO
CREATE VIEW vw_store_inventory AS
SELECT s.store_name, p.product_name, b.brand_name, c.category_name, st.quantity
FROM production.stocks st
JOIN sales.stores s ON st.store_id = s.store_id
JOIN production.products p ON st.product_id = p.product_id
JOIN production.brands b ON p.brand_id = b.brand_id
JOIN production.categories c ON p.category_id = c.category_id;
GO

-- Query the view for low stock
SELECT * FROM vw_store_inventory
WHERE quantity < 3;


-- ============================================================
-- SECTION C — ROW_NUMBER, RANK & DENSE_RANK
-- ============================================================

-- Q5: Top 2 best-selling products per store
WITH ProductSales AS (
    SELECT o.store_id, oi.product_id, SUM(oi.quantity) AS total_quantity
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY o.store_id, oi.product_id
),
Ranked AS (
    SELECT store_id, product_id, total_quantity,
           RANK() OVER (PARTITION BY store_id ORDER BY total_quantity DESC) AS rnk
    FROM ProductSales
)
SELECT * FROM Ranked
WHERE rnk IN (1,2);


-- Q6: 2nd most expensive product per category
WITH RankedProducts AS (
    SELECT category_id, product_name, list_price,
           RANK() OVER (PARTITION BY category_id ORDER BY list_price DESC) AS price_rank
    FROM production.products
)
SELECT category_id, product_name, list_price, price_rank
FROM RankedProducts
WHERE price_rank = 2;


-- Q7: Find duplicate customers in test_customers
SELECT customer_id, first_name, last_name, phone, city
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY first_name, last_name, phone ORDER BY customer_id) AS rn
    FROM test_customers
) t
WHERE rn > 1;   -- only duplicates, not first occurrence


-- ============================================================
-- SECTION D — LAG, LEAD & COALESCE
-- ============================================================

-- Q8: Month-by-month revenue report for 2017
WITH MonthlySales AS (
    SELECT YEAR(o.order_date) AS yr, MONTH(o.order_date) AS mn,
           SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS net_sales
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE YEAR(o.order_date) = 2017
    GROUP BY YEAR(o.order_date), MONTH(o.order_date)
)
SELECT mn, net_sales,
       LAG(net_sales) OVER (ORDER BY mn) AS previous_month_sales,
       net_sales - LAG(net_sales) OVER (ORDER BY mn) AS difference
FROM MonthlySales;


-- Q9: Product price vs next cheaper in same category
SELECT category_id, product_name, list_price,
       LEAD(list_price) OVER (PARTITION BY category_id ORDER BY list_price DESC) AS next_lower_price
FROM production.products
ORDER BY category_id, list_price DESC;


-- Q10: Customer contact info cleanup
SELECT (first_name + ' ' + last_name) AS full_name,
       COALESCE(phone, email, 'No Contact Info') AS contact_info,
       email
FROM sales.customers
ORDER BY last_name, first_name;