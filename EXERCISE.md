### Steps to Set Up the SExI System with Trino and Docker:

#### 1. Fork the Repository:
- Go to [https://github.com/sbms4d/wasb_sql_test](https://github.com/sbms4d/wasb_sql_test) and fork the repository.
- After forking, clone the forked repository locally using:
  ```bash
  git clone https://github.com/YOUR_USERNAME/wasb_sql_test.git
  ```

#### 2. Download and Install Docker Desktop:
- If Docker is not already installed, follow the instructions on [Docker Desktop installation page](https://docs.docker.com/get-docker/) to download and install Docker Desktop for your operating system.

#### 3. Pull the Trino Docker Image:
- Once Docker is installed, pull the `trinodb/trino` image from Docker Hub. Run the following command:
  ```bash
  docker pull trinodb/trino
  ```

#### 4. Start the SExI (Silverbullet Expenses and Invoices) Container:
- Now, create and start a Trino container with the name `sexi-silverbullet`. Use the following command:
  ```bash
  docker run --name=sexi-silverbullet -d trinodb/trino
  ```

#### 5. Reset the Database:
- If you ever need to reset the database (for testing or development), restart the container with:
  ```bash
  docker restart sexi-silverbullet
  ```

#### 6. Access the Trino SQL Shell:
- To interact with the Trino SQL engine and run SQL commands, access the Trino shell using:
  ```bash
  docker exec -it sexi-silverbullet trino
  ```

#### 7. Use the `memory.default` Schema:
- When working within Trino, ensure that you're using the correct catalog and schema for in-memory data storage:
  ```sql
  USE memory.default;
  ```

With these steps, you'll have the in-memory SExI database up and running via Trino inside a Docker container.

---

## STEP 1 - create_employees.sql

To create the `EMPLOYEE` table in the `SExI` database and insert the provided employee data, we will:

1. Create the table `EMPLOYEE` with the columns `employee_id`, `first_name`, `last_name`, `job_title`, and `manager_id`. We'll set `employee_id` and `manager_id` as `TINYINT` data types.
2. Populate the table with the data from the CSV.

### SQL Code

Here is the SQL code that you should place in your `create_employees.sql` file:

```sql
-- Create the EMPLOYEE table in the memory.default schema (without PRIMARY KEY)
CREATE TABLE EMPLOYEE (
    employee_id TINYINT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    job_title VARCHAR(50) NOT NULL,
    manager_id TINYINT
);

-- Insert data into the EMPLOYEE table
INSERT INTO EMPLOYEE (employee_id, first_name, last_name, job_title, manager_id) VALUES
(1, 'Ian', 'James', 'CEO', 4),
(2, 'Umberto', 'Torrielli', 'CSO', 1),
(3, 'Alex', 'Jacobson', 'MD EMEA', 2),
(4, 'Darren', 'Poynton', 'CFO', 2),
(5, 'Tim', 'Beard', 'MD APAC', 2),
(6, 'Gemma', 'Dodd', 'COS', 1),
(7, 'Lisa', 'Platten', 'CHR', 6),
(8, 'Stefano', 'Camisaca', 'GM Activation', 2),
(9, 'Andrea', 'Ghibaudi', 'MD NAM', 2);

```

### Key Points:
- The `employee_id` and `manager_id` columns use the `TINYINT` type to save space, as the values are small integers.
- `VARCHAR(50)` is used for `first_name`, `last_name`, and `job_title` to allow flexibility for storing text.
- A `PRIMARY KEY` constraint is added to ensure that each `employee_id` is unique.

Once this SQL is executed, it will create the `EMPLOYEE` table and insert the data as requested.

---

## STEP 2 - create_expenses.sql

To create the `EXPENSE` table and insert the expense data from the receipts, we will follow these steps:

1. **Create the `EXPENSE` table** with columns `employee_id` (linked to the `EMPLOYEE` table), `unit_price`, and `quantity`.
2. **Insert the expense data** from the provided receipt files into this table.

### SQL Code

Here is the SQL code that you should place in your `create_expenses.sql` file:

```sql
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
```

### Key Points:
- The `employee_id` is a foreign key referencing the `EMPLOYEE` table to maintain data consistency.
- `DECIMAL(8, 2)` is used for `unit_price` to handle currency with two decimal places.
- The `quantity` is a `TINYINT` since the values are small integers.

Once this SQL script is executed, the `EXPENSE` table will be created, and all the receipt data from the files will be inserted into the table.

---

## STEP 3 - create_invoices.sql

To manage the suppliers and invoices efficiently, we will:

1. **Create the `SUPPLIER` table** to store the supplier names with unique `supplier_id`.
2. **Create the `INVOICE` table** to store invoices along with their amounts and due dates.
3. **Assign `supplier_id` values based on the alphabetical order** of the supplier names.
4. **Insert the invoice data** with due dates set to the last day of the respective month.

### SQL Code

Here is the SQL code that you should place in your `create_invoices.sql` file:

```sql

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

```

### Explanation:
1. **SUPPLIER Table**: This table stores the supplier names with a `supplier_id` for each.
    - Suppliers are assigned IDs in alphabetical order: 
      - `Catering Plus` = 1, `Dave's Discos` = 2, `Entertainment Tonight` = 3, `Ice Ice Baby` = 4, and `Party Animals` = 5.
    
2. **INVOICE Table**: Stores the invoice details, such as the `invoice_amount` and `due_date`. The due date is calculated as the last day of the respective month using the SQL function `LAST_DAY()` combined with `DATE_ADD()` to move the current date forward by the required number of months.

3. **Due Dates**:
   - The due dates are calculated based on the specified timeframes in the files and adjusted to the last day of the corresponding month.

Once you run this SQL script, the suppliers and invoices will be created and inserted into the respective tables.

---

## STEP 4 - find_manager_cycles.sql

To identify cycles where employees are approving each other's expenses in the `SExI` database, we need to perform a **recursive query** to traverse the employee-manager relationships. Specifically, we will look for situations where an employee's manager indirectly loops back to the employee, indicating a cycle.

### Approach:
1. We will use a **recursive Common Table Expression (CTE)** to follow the chain of managers for each employee.
2. The query will check if any employee eventually reports to themselves via a cycle.
3. We will output the employee involved in the cycle and the sequence of employee IDs forming the cycle as a comma-separated string.

### SQL Code

Here’s the SQL code that you should place in your `find_manager_cycles.sql` file:

```sql
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

```

### Explanation:
1. **Recursive CTE (ManagerCycle)**: 
   - The base case starts with each employee and their direct manager.
   - The recursive part follows the chain of managers, constructing a path that tracks the sequence of employee IDs.
   - The `FIND_IN_SET` function is used to ensure that we do not revisit an employee ID that has already been added to the current path, avoiding infinite loops in the recursion.
   
2. **Final Result**:
   - The result is filtered to identify cases where an employee indirectly manages themselves, indicating a cycle.
   - The `employee_id` is the employee in the loop, and `cycle_path` shows the sequence of employees involved in the cycle.

### Output:
The output will contain two columns:
- `employee_id`: The ID of the employee involved in the cycle.
- `cycle_path`: The sequence of employee IDs that forms the cycle, as a comma-separated string.

Once this SQL script is executed, it will help you find all cycles of employees approving each other's expenses.

---

## STEP 5 - calculate_largest_expensors.sql

To generate the report of employees who have expensed more than 1000 in total, including their manager information, we will:

1. **Calculate the total expensed amount** for each employee, based on the `unit_price * quantity` for each `EXPENSE`.
2. **Join the `EMPLOYEE` table** with itself to get both the employee's name and their manager's name.
3. **Filter** to include only employees whose total expensed amount exceeds 1000.
4. **Sort the results** by the total expensed amount in descending order.

### SQL Code

Here is the SQL code that you should place in your `calculate_largest_expensors.sql` file:

```sql
--- Report employees who have expensed more than 1000 and their managers

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

```

### Explanation:
1. **Main Query**:
   - We join the `EMPLOYEE` table (`e`) with the `EXPENSE` table (`ex`) to calculate each employee's total expensed amount by multiplying `unit_price * quantity` and summing this across all their expenses.
   
2. **Self-Join for Manager Information**:
   - We perform a **left join** on the `EMPLOYEE` table (`m`) to get the manager's name by matching `e.manager_id` with `m.employee_id`. This allows us to pull the manager's first and last name.

3. **Filtering and Ordering**:
   - We use `HAVING total_expensed_amount > 1000` to only show employees who have expensed more than 1000.
   - The results are ordered in descending order by `total_expensed_amount`.

4. **Concatenation**:
   - We use `CONCAT()` to combine the employee's first and last names as well as the manager's first and last names into full names.

### Output:
The output will contain the following columns:
- `employee_id`: The ID of the employee who has exceeded the expense limit.
- `employee_name`: The full name of the employee.
- `manager_id`: The ID of the employee's manager.
- `manager_name`: The full name of the manager.
- `total_expensed_amount`: The total amount the employee has expensed.

Once this SQL script is executed, it will produce a report that shows who has expensed more than 1000, along with their manager's details, sorted by the highest total expensed amount.

---

## STEP 6 - generate_supplier_payment_plans.sql

To generate the monthly payment plan for suppliers based on the information provided, we need to:

1. **Calculate the total balance outstanding** for each supplier across all invoices.
2. **Distribute the payments evenly** for each supplier to ensure all invoices are paid off before their due date.
3. **Assign payments at the end of each month** until the full amount is paid.
4. **Handle suppliers with multiple invoices** by aggregating payments for each supplier, making sure they receive only one payment per month.

### Plan Outline:
- We will start by calculating the total balance per supplier.
- We'll calculate the number of months available until the due date for each supplier.
- Then, we'll generate monthly payments spread evenly across those months.
- If the total cannot be divided evenly (e.g., Catering Plus has invoices for 2000 and 1500), we'll assign the remaining balance to the next month's payment.

### SQL Code

Here’s the SQL code that you should place in your `generate_supplier_payment_plans.sql` file:

```sql
WITH supplier_invoices AS (
    -- Aggregate total invoice amounts and determine the latest due date for each supplier
    SELECT 
        s.supplier_id,
        s.name AS supplier_name,
        SUM(i.invoice_amount) AS total_balance,
        MAX(i.due_date) AS last_due_date
    FROM SUPPLIER s
    JOIN INVOICE i ON s.supplier_id = i.supplier_id
    GROUP BY s.supplier_id, s.name
),
payment_plan AS (
    -- Calculate the number of months between current date and the latest due date
    SELECT
        supplier_id,
        supplier_name,
        total_balance,
        last_due_date,
        -- Set the first payment date to the last day of the current month
        last_day_of_month(CURRENT_DATE) AS first_payment_date,
        -- Calculate the number of months between current date and last due date
        -- If due_date is in the past, set number_of_payments to 1
        GREATEST(
            CASE 
                WHEN last_due_date >= CURRENT_DATE THEN 
                    (EXTRACT(YEAR FROM last_due_date) - EXTRACT(YEAR FROM CURRENT_DATE)) * 12
                    + (EXTRACT(MONTH FROM last_due_date) - EXTRACT(MONTH FROM CURRENT_DATE)) + 1
                ELSE 1
            END,
            1
        ) AS number_of_payments
    FROM supplier_invoices
),
payment_schedule AS (
    -- Generate a sequence of payment dates for each supplier
    SELECT
        supplier_id,
        supplier_name,
        total_balance,
        last_due_date,
        first_payment_date,
        number_of_payments,
        -- Ensure the stop date is the last day of the due date's month
        sequence(
            first_payment_date,
            last_day_of_month(last_due_date),
            interval '1' month
        ) AS payment_dates
    FROM payment_plan
),
expanded_payments AS (
    -- Expand the payment_dates array into individual rows for each payment
    SELECT
        supplier_id,
        supplier_name,
        total_balance,
        payment_date,
        number_of_payments
    FROM payment_schedule
    CROSS JOIN UNNEST(payment_dates) AS t(payment_date)
),
calculated_payments AS (
    -- Assign payment amounts, distributing the total_balance evenly
    SELECT
        supplier_id,
        supplier_name,
        payment_date,
        total_balance,
        number_of_payments,
        ROW_NUMBER() OVER (PARTITION BY supplier_id ORDER BY payment_date) AS payment_number,
        -- Calculate base payment amount
        ROUND(total_balance / number_of_payments, 2) AS base_payment
    FROM expanded_payments
),
adjusted_payments AS (
    -- Adjust the last payment to account for any rounding discrepancies
    SELECT
        supplier_id,
        supplier_name,
        payment_date,
        CASE 
            WHEN payment_number < number_of_payments THEN base_payment
            ELSE ROUND(total_balance - (base_payment * (number_of_payments - 1)), 2)
        END AS payment_amount
    FROM calculated_payments
),
aggregated_payments AS (
    -- Aggregate payments per supplier per payment_date (one payment per month)
    SELECT 
        supplier_id,
        supplier_name,
        payment_amount,
        payment_date
    FROM adjusted_payments
),
cumulative_payments AS (
    -- Calculate cumulative payments to determine balance outstanding after each payment
    SELECT
        supplier_id,
        supplier_name,
        payment_date,
        payment_amount,
        SUM(payment_amount) OVER (PARTITION BY supplier_id ORDER BY payment_date) AS cumulative_payment
    FROM aggregated_payments
),
total_balances AS (
    -- Calculate the total outstanding balance for each supplier
    SELECT
        s.supplier_id,
        s.name AS supplier_name,
        SUM(i.invoice_amount) AS total_balance
    FROM SUPPLIER s
    JOIN INVOICE i ON s.supplier_id = i.supplier_id
    GROUP BY s.supplier_id, s.name
)
-- Final selection of the payment plan with balance outstanding
SELECT 
    cp.supplier_id,
    cp.supplier_name,
    cp.payment_amount,
    ROUND(tb.total_balance - cp.cumulative_payment, 2) AS balance_outstanding,
    cp.payment_date
FROM cumulative_payments cp
JOIN total_balances tb ON cp.supplier_id = tb.supplier_id
ORDER BY cp.supplier_id, cp.payment_date;

```
## Conclusion

By ensuring that the `sequence` function uses the **last day of the due date's month** as the stop value, you prevent scenarios where the stop date is earlier than the start date. This adjustment aligns the `payment_date` with the end of each month, ensuring consistent and error-free payment scheduling.

**Key Takeaways:**

- **Use `last_day_of_month(last_due_date)`** in the `sequence` function to align payment dates with month ends.
- **Ensure `number_of_payments`** accurately reflects the number of generated payment dates.
- **Handle Edge Cases** to prevent `sequence` function errors, especially when dealing with overdue invoices.

---

## STEP
