CREATE TABLE orders (
    id INT PRIMARY KEY,
    actor_id INT NOT NULL,
    total DECIMAL(12, 2) NOT NULL,
    status VARCHAR(40) NOT NULL
);

CREATE TRIGGER order_audit
ON orders
AFTER UPDATE
AS
BEGIN
    INSERT INTO audit_database.dbo.order_changes (order_id, status)
    SELECT id, status FROM inserted;
END;
