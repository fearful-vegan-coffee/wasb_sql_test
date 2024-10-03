USE memory.default;

-- Create the SUPPLIER table
CREATE TABLE SUPPLIER (
    supplier_id TINYINT NOT NULL,
    name VARCHAR(100) NOT NULL
);

-- Insert data into the SUPPLIER table, sorted alphabetically
INSERT INTO SUPPLIER (supplier_id, name) VALUES
(CAST(1 AS TINYINT), 'DJ Dance Madness'),
(CAST(2 AS TINYINT), 'Event Management Experts'),
(CAST(3 AS TINYINT), 'Fireworks R Us'),
(CAST(4 AS TINYINT), 'Kebab Emporium'),
(CAST(5 AS TINYINT), 'Spectacular Ice Creations');

-- Create the INVOICE table
CREATE TABLE INVOICE (
    supplier_id TINYINT NOT NULL,
    invoice_amount DECIMAL(8, 2) NOT NULL,
    due_date DATE NOT NULL
);

-- Insert data into the INVOICE table with explicit casting

-- Spectacular Ice Creations invoice
INSERT INTO INVOICE (supplier_id, invoice_amount, due_date) VALUES
    (1, 850.00, DATE '2024-10-31'),   
    (2, 3200.00, DATE '2024-11-30'),  
    (3, 2800.00, DATE '2024-12-31'),  
    (4, 45.00, DATE '2024-10-31'),    
    (5, 1250.00, DATE '2024-11-30');  
