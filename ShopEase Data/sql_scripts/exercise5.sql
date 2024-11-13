#A trigger that triggers on insert of an item into order_items\
#It decrements quantity of that item in the inventory table
DELIMITER //

CREATE TRIGGER update_inventory
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE current_stock BIGINT;

    -- Check the current stock for the product
    SELECT stock_quantity INTO current_stock
    FROM inventory
    WHERE id = NEW.product_id;

    -- if  there's enough stock, update the inventory
    IF current_stock >= NEW.quantity THEN
        UPDATE inventory
        SET stock_quantity = stock_quantity - NEW.quantity
        WHERE id = NEW.product_id;
    ELSE
        -- if the quantity in the inventory is not enough...
        -- '45000' signal thrown when a user defined exception is triggered
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock for the product.';
    END IF;
END //


DELIMITER ;
#Writing an insert into order_items to test if trigger functions as it is supposed to
INSERT INTO order_items (product_id, quantity, order_id) 
VALUES (1, 3, 102);  

#Checking out changes in the inventory table
#After looping through the trigger and the insert stock_quantity does decrease
SELECT stock_quantity FROM inventory
WHERE id = 1;


#A stored procedure that gives customers
DELIMITER //

#Create column: status in the customer table
ALTER TABLE customer
ADD status varchar(10);


CREATE PROCEDURE UpdateCustomerStatus(IN input_customer_id BIGINT)
BEGIN
    DECLARE total_order_value DOUBLE;

    -- Calculate the total order sum for the given customer
    SELECT SUM(order_sum) INTO total_order_value
    FROM orders
    WHERE customer_id = input_customer_id;

    -- Update the customer's status based on the total order value
    IF total_order_value > 10000 THEN
        UPDATE customer
        SET status = 'VIP'
        WHERE id = input_customer_id;
    ELSE
        UPDATE customer
        SET status = 'Regular'
        WHERE id = input_customer_id;
    END IF;
END //

DELIMITER ;

#Calling stored procedure
CALL UpdateCustomerStatus(1);
CALL UpdateCustomerStatus(2);

#Checking out changes in customer table
SELECT status FROM customer
WHERE id = 1 OR id =2;




