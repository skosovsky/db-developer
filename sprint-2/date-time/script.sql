-- выгрузить идентификаторы
SELECT customer_id,
       invoice_date,
       total
  FROM invoice
 WHERE customer_id BETWEEN 20 AND 50;

-- добавить данные о месяце и неделе заказа
SELECT customer_id,
       invoice_date,
       total,
       DATE_TRUNC('month', CAST(invoice_date AS TIMESTAMP)),
       EXTRACT(WEEK FROM CAST(invoice_date AS TIMESTAMP))
  FROM invoice
 WHERE customer_id BETWEEN 20 AND 50;

-- отфильтровать по номера недели
SELECT customer_id,
       invoice_date,
       total,
       DATE_TRUNC('month', CAST(invoice_date AS TIMESTAMP)),
       EXTRACT(WEEK FROM CAST(invoice_date AS TIMESTAMP))
  FROM invoice
 WHERE customer_id BETWEEN 20 AND 50
   AND EXTRACT(WEEK FROM CAST(invoice_date AS TIMESTAMP)) IN (5, 7, 10, 33, 48);

-- выгрузить данные с фильтрацией
SELECT invoice.*
  FROM invoice
           INNER JOIN client USING (customer_id)
 WHERE EXTRACT(DAY FROM CAST(invoice_date AS TIMESTAMP)) = 1
   AND client.company IS NULL;

-- выгрузить список сотрудников
SELECT email
  FROM staff
 WHERE city = 'Calgary'
   AND EXTRACT(YEAR FROM CAST(hire_date AS TIMESTAMP)) = 2002;
