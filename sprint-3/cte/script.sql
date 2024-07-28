-- заказы и клиенты по странам
  WITH invoices AS (SELECT billing_country AS country,
                           COUNT(total)    AS total_invoice
                      FROM invoice
                     GROUP BY billing_country
                     ORDER BY total_invoice DESC
                     LIMIT 5),
       clients  AS (SELECT country, COUNT(customer_id) AS total_clients
                      FROM client
                     GROUP BY country)
SELECT invoices.country,
       invoices.total_invoice,
       clients.total_clients
  FROM invoices
           LEFT JOIN clients USING (country)
 ORDER BY total_invoice DESC;

-- длинные фильмы и рейтинги
  WITH top_films AS (SELECT rating, film_id, length, rental_rate
                       FROM movie
                      WHERE rental_rate > 2
                      ORDER BY length DESC
                      LIMIT 40)
SELECT rating,
       MIN(length)      AS min_length,
       MAX(length)      AS max_length,
       AVG(length)      AS avg_length,
       MIN(rental_rate) AS min_rental_rate,
       MAX(rental_rate) AS max_rental_rate,
       AVG(rental_rate) AS avg_rental_rate
  FROM top_films
 GROUP BY rating
 ORDER BY avg_length;

-- анализ данных из invoice
  WITH months        AS (SELECT month
                           FROM GENERATE_SERIES(1, 12) AS month),
       invoices_2012 AS (SELECT EXTRACT(MONTH FROM invoice_date::DATE) AS month, SUM(total) AS total_month
                           FROM invoice
                          WHERE EXTRACT(YEAR FROM invoice_date::DATE) = 2012
                          GROUP BY month),
       invoices_2013 AS (SELECT EXTRACT(MONTH FROM invoice_date::DATE) AS month, SUM(total) AS total_month
                           FROM invoice
                          WHERE EXTRACT(YEAR FROM invoice_date::DATE) = 2013
                          GROUP BY month)
SELECT month,
       invoices_2012.total_month                                                AS sum_total_2012,
       invoices_2013.total_month                                                AS sum_total_2013,
       ROUND(invoices_2013.total_month / invoices_2012.total_month * 100) - 100 AS perc
  FROM months
           LEFT JOIN invoices_2012 USING (month)
           LEFT JOIN invoices_2013 USING (month)
 ORDER BY month;