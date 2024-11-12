#needs debugging
DELIMITER //

CREATE TRIGGER update_inventory
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
   
    DECLARE available_stock INT;
    
    -- Get the current inventory count for the product
    SELECT inventory_count INTO available_stock
    FROM Inventories
    WHERE id = NEW.id;
    
    IF available_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = CONCAT('Insufficient stock for product ID ', NEW.product_id);
    ELSE

        UPDATE Inventories
        SET inventory_count = inventory_count - NEW.quantity
        WHERE product_id = NEW.product_id;
    END IF;
END//

#Time 
DELIMITER ;
