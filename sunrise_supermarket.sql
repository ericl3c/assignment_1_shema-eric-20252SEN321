create database sunrise_supermarket;
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price NUMERIC(10,2)
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    order_date DATE
);

CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER
);


INSERT INTO customers VALUES (1, 'Eric Shema', 'eric@gmail.com', 'Kigali');
INSERT INTO customers VALUES (2, 'Justin Ntiganzwa', 'justin@gmail.com', 'Musanze');
INSERT INTO customers VALUES (3, 'Asante Ikirezi', 'asante@gmail.com', 'Huye');
INSERT INTO customers VALUES (4, 'Ines Ishimwe', 'ines@gmail.com', 'Rubavu');
INSERT INTO customers VALUES (5, 'King Tony', 'tony@gmail.com', 'Kigali');

COMMIT;


INSERT INTO products VALUES (1, 'Rice', 'Food', 2500);
INSERT INTO products VALUES (2, 'Sugar', 'Food', 1800);
INSERT INTO products VALUES (3, 'Milk', 'Dairy', 1500);
INSERT INTO products VALUES (4, 'Cheese', 'Dairy', 4500);
INSERT INTO products VALUES (5, 'Soap', 'Household', 1200);
INSERT INTO products VALUES (6, 'Toothpaste', 'Personal Care', 2500);
INSERT INTO products VALUES (7, 'Bread', 'Bakery', 1500);
INSERT INTO products VALUES (8, 'Cooking Oil', 'Food', 5000);

COMMIT;


INSERT INTO orders VALUES (1, 1, DATE '2026-09-01');
INSERT INTO orders VALUES (2, 2, DATE '2026-09-02');
INSERT INTO orders VALUES (3, 3, DATE '2026-09-03');
INSERT INTO orders VALUES (4, 4, DATE '2026-09-04');
INSERT INTO orders VALUES (5, 5, DATE '2026-09-05');

INSERT INTO orders VALUES (6, 1, DATE '2026-09-07');
INSERT INTO orders VALUES (7, 2, DATE '2026-09-08');
INSERT INTO orders VALUES (8, 3, DATE '2026-09-10');
INSERT INTO orders VALUES (9, 4, DATE '2026-09-11');
INSERT INTO orders VALUES (10, 5, DATE '2026-09-12');

INSERT INTO orders VALUES (11, 1, DATE '2026-09-14');
INSERT INTO orders VALUES (12, 2, DATE '2026-09-15');
INSERT INTO orders VALUES (13, 3, DATE '2026-09-17');
INSERT INTO orders VALUES (14, 4, DATE '2026-09-18');
INSERT INTO orders VALUES (15, 5, DATE '2026-09-20');

COMMIT;
INSERT INTO order_items VALUES (1, 1, 1, 2);
INSERT INTO order_items VALUES (2, 1, 3, 1);

INSERT INTO order_items VALUES (3, 2, 2, 3);
INSERT INTO order_items VALUES (4, 2, 7, 2);

INSERT INTO order_items VALUES (5, 3, 4, 1);
INSERT INTO order_items VALUES (6, 3, 5, 2);

INSERT INTO order_items VALUES (7, 4, 6, 2);
INSERT INTO order_items VALUES (8, 4, 8, 1);

INSERT INTO order_items VALUES (9, 5, 1, 3);
INSERT INTO order_items VALUES (10, 5, 7, 1);

INSERT INTO order_items VALUES (11, 6, 8, 2);
INSERT INTO order_items VALUES (12, 6, 3, 2);

INSERT INTO order_items VALUES (13, 7, 1, 4);
INSERT INTO order_items VALUES (14, 7, 5, 2);

INSERT INTO order_items VALUES (15, 8, 2, 3);
INSERT INTO order_items VALUES (16, 8, 6, 1);

INSERT INTO order_items VALUES (17, 9, 4, 2);
INSERT INTO order_items VALUES (18, 9, 7, 2);

INSERT INTO order_items VALUES (19, 10, 8, 1);
INSERT INTO order_items VALUES (20, 10, 5, 3);

INSERT INTO order_items VALUES (21, 11, 1, 2);
INSERT INTO order_items VALUES (22, 11, 3, 2);

INSERT INTO order_items VALUES (23, 12, 2, 5);
INSERT INTO order_items VALUES (24, 12, 7, 2);

INSERT INTO order_items VALUES (25, 13, 4, 1);
INSERT INTO order_items VALUES (26, 13, 6, 2);

INSERT INTO order_items VALUES (27, 14, 8, 2);
INSERT INTO order_items VALUES (28, 14, 5, 1);

INSERT INTO order_items VALUES (29, 15, 1, 3);
INSERT INTO order_items VALUES (30, 15, 3, 2);

COMMIT;
SELECT
    o.order_id,
    c.customer_name,
    c.city,
    o.order_date
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
ORDER BY o.order_date;

SELECT
    oi.order_item_id,
    oi.order_id,
    p.product_name,
    p.category,
    p.price,
    oi.quantity
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id
ORDER BY oi.order_id;

SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    o.order_id,
    o.order_date
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.order_date;


WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * p.price) AS total_spend
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    JOIN products AS p
        ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_spend
FROM customer_totals
WHERE total_spend > (
    SELECT AVG(total_spend)
    FROM customer_totals
)
ORDER BY total_spend DESC;

WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * p.price) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_spent,
    RANK() OVER (
        ORDER BY total_spent DESC
    ) AS spending_rank
FROM customer_totals
ORDER BY spending_rank;


SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    ROW_NUMBER() OVER (
        PARTITION BY o.customer_id
        ORDER BY o.order_date
    ) AS order_number
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
ORDER BY c.customer_name, o.order_date;

WITH order_revenue AS (
    SELECT
        o.order_id,
        o.order_date,
        SUM(oi.quantity * p.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY o.order_id, o.order_date
)
SELECT
    order_id,
    order_date,
    revenue,
    SUM(revenue) OVER (
        ORDER BY order_date, order_id
    ) AS running_total_revenue
FROM order_revenue
ORDER BY order_date, order_id;

SELECT
    customer_name,
    order_id,
    order_date,
    previous_order_date,
    order_date - previous_order_date AS days_between_orders
FROM (
    SELECT
        c.customer_name,
        o.customer_id,
        o.order_id,
        o.order_date,
        LAG(o.order_date) OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date
        ) AS previous_order_date
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
) AS customer_orders
WHERE previous_order_date IS NOT NULL
ORDER BY customer_name, order_date;

