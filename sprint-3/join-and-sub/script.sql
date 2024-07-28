-- 5 топ стран по заказам join
SELECT billing_country AS country, COUNT(invoice.invoice_id) AS total_invoice, COUNT(DISTINCT client.customer_id) AS total_clients
  FROM invoice
           INNER JOIN client USING (customer_id)
 GROUP BY billing_country
 ORDER BY total_invoice DESC, total_clients
 LIMIT 5;

-- 5 топ стран по заказам sub
SELECT *
  FROM (SELECT billing_country           AS country,
               COUNT(invoice.invoice_id) AS total_invoice
          FROM invoice
         GROUP BY billing_country
         ORDER BY total_invoice DESC
         LIMIT 5) AS countries
           LEFT JOIN (SELECT country, COUNT(customer_id) AS total_clients
                        FROM client
                       GROUP BY country) AS clients USING (country)
 ORDER BY countries.total_invoice DESC;

-- проверим на ошибки в отчете
-- подзапрос 1
SELECT EXTRACT(MONTH FROM invoice_date::DATE) AS month_invoice, SUM(total) AS sum_total
  FROM invoice
 WHERE EXTRACT(YEAR FROM invoice_date::DATE) = 2010
 GROUP BY month_invoice;

-- подзапрос 2
SELECT EXTRACT(MONTH FROM invoice_date::DATE) AS month_invoice, SUM(unit_price * invoice_line.quantity) AS sum_price
  FROM invoice
           LEFT JOIN invoice_line USING (invoice_id)
 WHERE EXTRACT(YEAR FROM invoice_date::DATE) = 2010
 GROUP BY month_invoice;

-- объединенный запрос
SELECT month_invoice,
       sum_total,
       sum_price
  FROM (SELECT EXTRACT(MONTH FROM invoice_date::DATE) AS month_invoice, SUM(total) AS sum_total
          FROM invoice
         WHERE EXTRACT(YEAR FROM invoice_date::DATE) = 2010
         GROUP BY month_invoice) AS total_invoices
           INNER JOIN (SELECT EXTRACT(MONTH FROM invoice_date::DATE) AS month_invoice, SUM(unit_price * invoice_line.quantity) AS sum_price
                         FROM invoice
                                  LEFT JOIN invoice_line USING (invoice_id)
                        WHERE EXTRACT(YEAR FROM invoice_date::DATE) = 2010
                        GROUP BY month_invoice) AS total_prices_quantity USING (month_invoice);

-- сводная таблица с заказами
-- подзапрос 1
SELECT invoice_month
  FROM GENERATE_SERIES(1, 12, 1) AS invoice_month;

-- подзапрос 2
SELECT EXTRACT(MONTH FROM invoice_date::DATE) AS invoice_month, COUNT(invoice_id)
  FROM invoice
 WHERE EXTRACT(YEAR FROM invoice_date::DATE) = 2011
 GROUP BY invoice_month;

-- полный запрос
SELECT invoice_month, year_2011, year_2012, year_2013
  FROM GENERATE_SERIES(1, 12, 1) AS invoice_month
           LEFT JOIN (SELECT EXTRACT(MONTH FROM invoice_date::DATE) AS invoice_month, COUNT(invoice_id) AS year_2011
                        FROM invoice
                       WHERE EXTRACT(YEAR FROM invoice_date::DATE) = 2011
                       GROUP BY invoice_month) AS year_2011 USING (invoice_month)
           LEFT JOIN (SELECT EXTRACT(MONTH FROM invoice_date::DATE) AS invoice_month, COUNT(invoice_id) AS year_2012
                        FROM invoice
                       WHERE EXTRACT(YEAR FROM invoice_date::DATE) = 2012
                       GROUP BY invoice_month) AS year_2012 USING (invoice_month)
           LEFT JOIN (SELECT EXTRACT(MONTH FROM invoice_date::DATE) AS invoice_month, COUNT(invoice_id) AS year_2013
                        FROM invoice
                       WHERE EXTRACT(YEAR FROM invoice_date::DATE) = 2013
                       GROUP BY invoice_month) AS year_2013 USING (invoice_month);

-- отберите уникальные фамилии с параметрами
-- подзапрос 1
SELECT customer_id
  FROM invoice
 WHERE invoice_date::DATE BETWEEN '2013-01-01' AND '2013-01-31';

-- подзапрос 2
SELECT DISTINCT customer_id
  FROM invoice
 WHERE invoice_date::DATE BETWEEN '2013-02-01' AND '2013-12-31'
   AND customer_id IN (SELECT customer_id
                         FROM invoice
                        WHERE invoice_date::DATE BETWEEN '2013-01-01' AND '2013-01-31');

-- полный запрос
SELECT DISTINCT last_name
  FROM client
 WHERE customer_id IN (SELECT customer_id
                         FROM invoice
                        WHERE invoice_date::DATE BETWEEN '2013-02-01' AND '2013-12-31'
                          AND customer_id IN (SELECT customer_id
                                                FROM invoice
                                               WHERE invoice_date::DATE BETWEEN '2013-01-01' AND '2013-01-31'));

-- статистика по категориям фильмов
-- подзапрос 1
SELECT actor_id
FROM film_actor
INNER JOIN movie USING (film_id)
WHERE release_year > 2013
GROUP BY actor_id
HAVING COUNT(actor_id) > 7;

-- запрос
SELECT name AS name_category, COUNT(DISTINCT film_id) AS total_films
  FROM category
           INNER JOIN film_category USING (category_id)
           INNER JOIN film_actor USING (film_id)
 WHERE actor_id IN (SELECT actor_id
                      FROM film_actor
                               INNER JOIN movie USING (film_id)
                     WHERE release_year > 2013
                     GROUP BY actor_id
                    HAVING COUNT(actor_id) > 7)
 GROUP BY name
 ORDER BY total_films DESC, name_category;