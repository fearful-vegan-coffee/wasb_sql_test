USE memory.default;

-- Find manager approval cycles in EMPLOYEE table

WITH RECURSIVE employee_chain (employee_id, manager_id, cycle_path) AS (
    -- Start with each employee and their manager
    SELECT 
        e.employee_id,
        e.manager_id,
        CAST(e.employee_id AS VARCHAR) AS cycle_path
    FROM EMPLOYEE e
    
    UNION ALL
    
    -- Recursively follow the chain of managers, stopping if a cycle is detected
    SELECT 
        c.employee_id,
        m.manager_id,
        CONCAT(c.cycle_path, ',', CAST(m.employee_id AS VARCHAR)) AS cycle_path
    FROM employee_chain c
    JOIN EMPLOYEE m ON c.manager_id = m.employee_id
    WHERE m.employee_id != c.employee_id 
    AND POSITION(CAST(m.employee_id AS VARCHAR) IN c.cycle_path) = 0 -- Stop if employee_id is already in the cycle_path
)

-- Final query to detect cycles
SELECT 
    employee_id, 
    cycle_path
FROM employee_chain
WHERE employee_id IN (SELECT manager_id FROM EMPLOYEE)
AND employee_id != manager_id;
