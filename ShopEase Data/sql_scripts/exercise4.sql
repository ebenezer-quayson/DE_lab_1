#Queries in exercise 3 are rerun with the EXPLAIN keyword to see how better they run

EXPLAIN SELECT 
    o.product_id,
    p.product_name,
    SUM(o.order_sum) AS total_order_sum,
    ROW_NUMBER() OVER (ORDER BY SUM(o.order_sum) DESC) AS _row,
    RANK() OVER (ORDER BY SUM(o.order_sum) DESC) AS _rank,
    DENSE_RANK() OVER (ORDER BY SUM(o.order_sum) DESC) AS _dense_rank
FROM 
    orders o
JOIN 
    products p ON o.product_id = p.id
WHERE 
    MONTH(o.order_date) = 11 AND YEAR(o.order_date) = 2024  -- Optional filter for November 2024
GROUP BY 
    o.product_id, p.product_name
ORDER BY 
    total_order_sum DESC; 
#Running totals
EXPLAIN SELECT
    p.category,
    p.product_name,
    o.order_date,
    o.order_sum,
    SUM(o.order_sum) OVER (PARTITION BY p.category ORDER BY o.order_date) AS running_total
FROM
    orders o
JOIN
    products p ON o.product_id = p.id
ORDER BY
    p.category, o.order_date;
    
    


    
#Has the customer repeating 
EXPLAIN SELECT 
    o.customer_id,
    c.customer_name,
    o.order_date,
    o.order_sum,
    AVG(o.order_sum) OVER (PARTITION BY o.customer_id) AS avg_order_value
FROM 
    orders o
JOIN 
    customer c ON o.customer_id = c.id
ORDER BY 
    o.customer_id, o.order_date;
    
#Customer does not repeat
EXPLAIN SELECT 
    o.customer_id,
    c.customer_name,
    AVG(o.order_sum) AS avg_order_value
FROM 
    orders o
JOIN 
    customer c ON o.customer_id = c.id
GROUP BY 
    o.customer_id, c.customer_name
ORDER BY 
    avg_order_value DESC;


EXPLAIN SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(order_sum) AS total_sales,
    LAG(SUM(order_sum)) OVER (ORDER BY YEAR(order_date), MONTH(order_date)) AS previous_month_sales,
    LEAD(SUM(order_sum)) OVER (ORDER BY YEAR(order_date), MONTH(order_date)) AS next_month_sales
FROM
    orders
GROUP BY 
    YEAR(order_date), MONTH(order_date)
ORDER BY 
    year, month;



EXPLAIN SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(order_sum) AS total_sales,
    SUM(SUM(order_sum)) OVER (ORDER BY YEAR(order_date), MONTH(order_date)) AS running_total_sales,
    DENSE_RANK() OVER (ORDER BY SUM(order_sum) DESC) AS dense_rank_sales,
    RANK() OVER (ORDER BY SUM(order_sum) DESC) AS rank_sales
FROM
    orders
GROUP BY 
    YEAR(order_date), MONTH(order_date)
ORDER BY 
    year, month;


#Indexes created for customer_id and product_id in orders
CREATE INDEX idx_customer_id ON orders(customer_id);
CREATE INDEX idx_product_id ON orders(product_id);


#Create new primary key id for inventory to make sure 1NF is achieved
ALTER TABLE inventory
ADD id int AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE suppliers_data
ADD supplier_id int AUTO_INCREMENT PRIMARY KEY;

#Table created but was unable to insert the data from suppliers_data
CREATE TABLE suppliers_partitioned (
    supplier_id INT,
    supplier_name VARCHAR(100),
    supplier_address VARCHAR(255),
    email VARCHAR(100),
    contact_number VARCHAR(20),
    fax VARCHAR(20),
    account_number VARCHAR(50),
    order_history TEXT,
    contract TEXT,
    supplier_country VARCHAR(100),
    supplier_city VARCHAR(100),
    country_code VARCHAR(10),
    country_code_int INT,  -- Integer version of the country code for partitioning
    PRIMARY KEY (supplier_id, country_code_int)  -- Composite primary key
)
PARTITION BY RANGE (country_code_int) (
    PARTITION p_germany VALUES LESS THAN (2),
    PARTITION p_usa VALUES LESS THAN (3),
    PARTITION p_uk VALUES LESS THAN (4),
    PARTITION p_canada VALUES LESS THAN (MAXVALUE)
);


INSERT INTO suppliers_partitioned (supplier_id, supplier_name, supplier_address, email, contact_number, fax, account_number, order_history, contract, supplier_country, supplier_city, country_code, country_code_int)
SELECT supplier_id, supplier_name, supplier_address, email, contact_number, fax, account_number, order_history, contract, supplier_country, supplier_city, country_code,
       -- Use a CASE statement to map country names to integer values
       CASE 
           WHEN country_code = 'Germany' THEN 1  
           WHEN country_code = 'USA' THEN 2   
           WHEN country_code = 'UK' THEN 3 
           WHEN country_code = 'Canada' THEN 4
           ELSE 5                         
       END AS country_code_int
FROM suppliers_data;


SELECT * FROM suppliers_partitioned





























