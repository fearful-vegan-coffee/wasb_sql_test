USE memory.default;

-- Report employees who have expensed more than 1000 and their managers

SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.manager_id,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name,
    SUM(ex.unit_price * ex.quantity) AS total_expensed_amount
FROM EMPLOYEE e
JOIN EXPENSE ex ON e.employee_id = ex.employee_id
LEFT JOIN EMPLOYEE m ON e.manager_id = m.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.manager_id, m.first_name, m.last_name
HAVING SUM(ex.unit_price * ex.quantity) > 1000
ORDER BY total_expensed_amount DESC;
