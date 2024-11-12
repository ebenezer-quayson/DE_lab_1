#Still confused about these windown functions.
#Will come back to them
#rank row_number dense_rank
SELECT 
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
SELECT
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
SELECT 
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
SELECT 
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


SELECT
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



SELECT
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

