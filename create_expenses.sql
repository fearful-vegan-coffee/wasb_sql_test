USE memory.default;

-- Create the EXPENSE table
CREATE TABLE EXPENSE (
    employee_id TINYINT NOT NULL,
    unit_price DECIMAL(8, 2) NOT NULL,
    quantity TINYINT NOT NULL
);

-- Insert data into the EXPENSE table
-- Expenses for Alex Jacobson (employee_id = 3)
INSERT INTO EXPENSE (employee_id, unit_price, quantity) VALUES
(3, 6.50, 14), -- Drinks, lots of drinks
(3, 11.00, 20), -- More Drinks
(3, 22.00, 18), -- So Many Drinks!
(3, 13.00, 75); -- I bought everyone in the bar a drink!

-- Expenses for Andrea Ghibaudi (employee_id = 9)
INSERT INTO EXPENSE (employee_id, unit_price, quantity) VALUES
(9, 300.00, 1); -- Flights from Mexico back to New York

-- Expenses for Darren Poynton (employee_id = 4)
INSERT INTO EXPENSE (employee_id, unit_price, quantity) VALUES
(4, 40.00, 9); -- Ubers to get us all home

-- Expenses for Umberto Torrielli (employee_id = 2)
INSERT INTO EXPENSE (employee_id, unit_price, quantity) VALUES
(2, 17.50, 4); -- I had too much fun and needed something to eat