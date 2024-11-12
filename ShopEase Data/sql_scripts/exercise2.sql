#This block changes the columns tagged as 'id' for the orders, customer, product tables
# Made sense to alter the column names
# Columns noting ids should not have names that suggest they refer to a different table
#0.016 for column alterations average
ALTER TABLE customer
RENAME COLUMN customer_id TO id;

ALTER TABLE products
RENAME COLUMN product_id TO id;

ALTER TABLE orders
RENAME COLUMN order_id TO id;


#This block joins the orders, product and customer tables
# A lot of ambiguity in not calling out the columns singularly
# Ambiguity is fixed by calling out the columns individualy and altering the neccessary column names temporarliy to quell the duplicate errors
#THis statement moved from 0.043s to 0.00s because of the primary keys being used as the conditionals for the joins

SELECT 
	c.id AS customer_customer_id,
    c.customer_name,
    c.email,
    c.join_date,
    o.id AS order_order_id,
    o.customer_id AS order_customer_id,
    o.order_date,
    o.product_id AS order_product_id,
    o.quantity,
    o.order_sum,
    p.id AS product_product_id,
    p.product_name,
    p.category,
    p.price
    
FROM
	customer c
JOIN 
	orders o ON  o.customer_id = c.id
JOIN
	products p ON  p.id = o.product_id;



#Checking my orders to see if there were no orders in October, 2024
#Answer: NO. As a result I assumed the past month is November, 2024
SELECT * FROM orders
WHERE order_date LIKE '2024-10%';


# For optimization I declared the id columns in the three tables: customer, products and orders tables since they are used a lot considerably in joins 
#I it kills two birds with one stone since primary keys are automatically indexed
#Indexing the product_id column and product_id columns in orders does not seem to have any effect on the joins

