USE memory.default;

TRUNCATE TABLE INVOICE;

-- Insert new test invoices into the INVOICE table
INSERT INTO INVOICE (supplier_id, invoice_amount, due_date) VALUES
    (1, 850.00, DATE '2024-10-31'),   
    (2, 3200.00, DATE '2024-11-30'),  
    (3, 2800.00, DATE '2024-12-31'),  
    (4, 45.00, DATE '2024-10-31'),    
    (5, 1250.00, DATE '2024-11-30');  

    SELECT * FROM INVOICE;
    

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
