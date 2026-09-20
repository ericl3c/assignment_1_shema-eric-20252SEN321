# Sunrise Supermarket – SQL Assignment One

## Student Information

* **Name:** SHEMA Eric
* **Student ID:** 20252SEN321
* **Database Management System:** PostgreSQL
* **Repository:** `assignment_1_shema-eric-20252SEN321`

---

## 1. Project Summary

This project is a database assignment based on a **Sunrise Supermarket** business scenario.

The database is designed to manage:

* Customers
* Products
* Product categories
* Orders
* Order items
* Customer purchases
* Sales revenue

The project demonstrates the use of **JOINs, Common Table Expressions (CTEs), and Window Functions** in PostgreSQL.

The database contains:

* 5 customers
* 8 products
* 4 product categories
* 15 orders
* 30 order items
* Orders distributed across multiple dates

---

## 2. Business Scenario

Sunrise Supermarket needs a database system to track customers, products, orders, and sales.

The database allows the supermarket to answer questions such as:

* Which customers placed orders?
* What products were purchased?
* Which customers spent more than the average?
* Which customers spent the most money?
* How many orders has each customer placed?
* What is the running total of supermarket revenue?
* How many days are between a customer's orders?

These queries can help supermarket management understand customer purchasing behavior and sales performance.

---

## 3. Database Tables

The database contains four main tables:

### Customers

Stores information about supermarket customers.

| Column        | Description        |
| ------------- | ------------------ |
| customer_id   | Unique customer ID |
| customer_name | Customer name      |
| email         | Customer email     |
| city          | Customer city      |

### Products

Stores information about products sold by the supermarket.

| Column       | Description       |
| ------------ | ----------------- |
| product_id   | Unique product ID |
| product_name | Product name      |
| category     | Product category  |
| price        | Product price     |

### Orders

Stores customer orders.

| Column      | Description                   |
| ----------- | ----------------------------- |
| order_id    | Unique order ID               |
| customer_id | Customer who placed the order |
| order_date  | Date of the order             |

### Order Items

Stores products included in each order.

| Column        | Description          |
| ------------- | -------------------- |
| order_item_id | Unique order-item ID |
| order_id      | Related order        |
| product_id    | Purchased product    |
| quantity      | Quantity purchased   |

---

## 4. How to Run the Project

### Step 1: Install PostgreSQL

Install PostgreSQL and open **pgAdmin** or **psql**.

### Step 2: Create a Database

Create a database named:

```text
sunrise_supermarket
```

### Step 3: Open the SQL File

Open:

```text
sunrise_supermarket.sql
```

### Step 4: Execute the SQL Script

Run the script in PostgreSQL.

The script creates the tables and inserts the required sample data.

### Step 5: Run the Queries

Execute the JOIN, CTE, and Window Function queries individually to view their results.

---

# 5. JOIN Queries

## JOIN Query 1 – Orders with Customer Information

This query uses an `INNER JOIN` to connect the `orders` table with the `customers` table.

```sql
SELECT
    o.order_id,
    c.customer_name,
    c.city,
    o.order_date
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
ORDER BY o.order_date;
```

### Explanation

The query displays the order ID, customer name, customer city, and order date.

The `INNER JOIN` connects each order to the customer who placed it.

### Business Interpretation

This helps Sunrise Supermarket identify which customers placed orders and when the orders were made.

---

## JOIN Query 2 – Order Items with Product Information

```sql
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
ORDER BY oi.order_id, oi.order_item_id;
```

### Explanation

The query connects order items with products to display product names, categories, prices, and quantities.

### Business Interpretation

The supermarket can use this information to understand which products customers purchased and the quantity purchased.

---

## JOIN Query 3 – All Customers and Their Orders

```sql
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
```

### Explanation

A `LEFT JOIN` is used so that all customers are displayed, even if a customer has no order.

### Business Interpretation

This can help the supermarket identify both active customers and customers who have not placed any orders.

---

# 6. Common Table Expression (CTE)

## Customers Spending Above the Average

```sql
WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * p.price) AS total_spend
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY
        c.customer_id,
        c.customer_name
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
```

### Explanation

The CTE calculates the total amount spent by each customer.

The main query then compares each customer's spending with the average customer spending.

### Business Interpretation

This helps management identify customers who spend more than the average customer.

---

# 7. Window Functions

## Window Function 1 – Rank Customers by Total Spending

```sql
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
```

### Explanation

The query calculates the total amount spent by each customer.

The `RANK()` window function ranks customers from the highest spending to the lowest spending.

### Business Interpretation

The supermarket can use this information to understand customer spending levels and customer purchasing behavior.

---

## Window Function 2 – Number Each Customer's Orders

```sql
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
```

### Explanation

`ROW_NUMBER()` assigns a sequential number to each customer's orders.

`PARTITION BY` makes the numbering restart for every customer.

### Business Interpretation

This helps the supermarket track the sequence of orders made by each customer.

---

## Window Function 3 – Running Total of Revenue

```sql
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
```

### Explanation

The CTE first calculates revenue for each order.

The window function then calculates the cumulative revenue over time.

### Business Interpretation

Management can use the running total to monitor how supermarket revenue grows over the period.

---

## Window Function 4 – Days Between Customer Orders

```sql
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
```

### Explanation

The `LAG()` function retrieves the previous order date for each customer.

PostgreSQL then subtracts the previous date from the current date to calculate the number of days between orders.

The first order for each customer is excluded because it does not have a previous order.

### Business Interpretation

This helps the supermarket understand customer ordering frequency and identify how often customers return to purchase products.

---

# 8. Results Summary

Based on the sample data:

### Customer Total Spending

| Customer         | Total Spending |
| ---------------- | -------------: |
| Ines Ishimwe     |         33,200 |
| Justin Ntiganzwa |         32,800 |
| King Tony        |         28,100 |
| Eric Shema       |         27,500 |
| Asante Ikirezi   |         24,300 |

The average customer spending is:

```text
29,180
```

Customers whose spending is above the average are:

```text
Ines Ishimwe – 33,200
Justin Ntiganzwa – 32,800
```

### Total Revenue

The total revenue from the 15 orders is:

```text
145,900 RWF
```

---

# 9. Screenshots

Screenshots of the query results should be placed in the `screenshots` folder.

Recommended files:

```text
screenshots/
├── join1.png
├── join2.png
├── join3.png
├── cte.png
├── window1.png
├── window2.png
├── window3.png
└── window4.png
```

Each screenshot should clearly show the SQL query and its result in PostgreSQL/pgAdmin.

---

# 10. Project Structure

```text
assignment_1_shema-eric-20252SEN321/
│
├── README.md
├── sunrise_supermarket.sql
│
└── screenshots/
    ├── join1.png
    ├── join2.png
    ├── join3.png
    ├── cte.png
    ├── window1.png
    ├── window2.png
    ├── window3.png
    └── window4.png
```

---

# 11. Challenges and Solutions

### Challenge 1: Understanding JOINs

At first, it was difficult to understand how the different tables were connected.

**Solution:**
I used primary keys and foreign keys to understand the relationships between customers, orders, products, and order items.

### Challenge 2: Understanding CTEs

Understanding how a CTE can be used as a temporary result was challenging.

**Solution:**
I separated the calculation of customer spending into a CTE and then used the result in the main query.

### Challenge 3: Understanding Window Functions

Functions such as `RANK()`, `ROW_NUMBER()`, and `LAG()` were initially difficult to understand.

**Solution:**
I practiced each function separately and used `PARTITION BY` and `ORDER BY` to understand how the rows are processed.

---

# 12. Conclusion

This assignment provided practical experience in PostgreSQL database management.

The project demonstrated how SQL can be used to:

* Connect multiple tables using JOINs.
* Calculate customer spending using a CTE.
* Rank customers using `RANK()`.
* Number customer orders using `ROW_NUMBER()`.
* Calculate cumulative revenue using a running total.
* Calculate the number of days between customer orders using `LAG()`.

The database demonstrates how SQL queries can provide useful information for business decision-making in a supermarket environment.

---

## Author

**SHEMA Eric**
**Student ID: 20252SEN321**
**Database: PostgreSQL**
