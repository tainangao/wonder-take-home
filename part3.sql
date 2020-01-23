

SELECT customers.customer_name, SUM(COALESCE(orders.order_amt, 0)) AS total_2009
FROM customers
-- In orders table, customer #1 has 2 orders. Using LEFT JOIN will only keep 1 order
-- Need to use RIGHT JOIN to keep all orders
LEFT OUTER JOIN orders ON ( customers.customer_nbr = orders.customer_nbr) 
-- The date format is different from the one in the orders table
WHERE orders.order_date >= ‘20090101’ 
GROUP BY customers.customer_name

-- Since only customers who placed orders would be kept, 
-- there's no need to use COALESCE()
SELECT customers.customer_name, SUM(orders.order_amt) AS total_2009
FROM customers
RIGHT OUTER JOIN orders ON ( customers.customer_nbr = orders.customer_nbr) 
WHERE orders.order_date >= ‘2009-01-01’ 
GROUP BY customers.customer_name;


