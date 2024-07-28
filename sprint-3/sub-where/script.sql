-- собрать информацию о 10 самых крупных заказах
SELECT *
  FROM client
 WHERE customer_id IN (SELECT customer_id
                         FROM invoice
                        GROUP BY customer_id
                        ORDER BY SUM(total) DESC
                        LIMIT 10);

-- средняя стоимость фильмов с условиями
SELECT AVG(rental_rate)
  FROM movie
 WHERE film_id IN (SELECT film_id
                     FROM movie
                              LEFT JOIN film_actor USING (film_id)
                    GROUP BY film_id
                   HAVING COUNT(actor_id) > 12)
   AND length <= (SELECT AVG(length)
                    FROM movie);

-- сравнение выручки
-- подзапрос 1
SELECT invoice_id
  FROM invoice_line
 GROUP BY invoice_id
HAVING COUNT(track_id) > 5;

-- подзапрос 2
SELECT AVG(unit_price)
  FROM invoice_line;

-- объединенный запрос
SELECT billing_country,
       ROUND(MIN(total), 2) AS min_total,
       ROUND(MAX(total), 2) AS max_total,
       ROUND(AVG(total), 2) AS avg_total
  FROM invoice
 WHERE invoice_id IN (SELECT invoice_id
                        FROM invoice_line
                       GROUP BY invoice_id
                      HAVING COUNT(invoice_id) > 5)
   AND total > (SELECT AVG(unit_price)
                  FROM invoice_line)
 GROUP BY billing_country
 ORDER BY avg_total DESC, billing_country;

-- 2 коротких фильма, укажите их жанры
SELECT genre.name
  FROM genre
           INNER JOIN track USING (genre_id)
 WHERE track_id IN (SELECT track_id
                      FROM track
                     ORDER BY milliseconds
                     LIMIT 2);

-- уникальные города, где стоимость заказов больше максимального за 2009
SELECT DISTINCT(billing_city)
  FROM invoice
 WHERE total > (SELECT MAX(total)
                  FROM invoice
                 WHERE EXTRACT(YEAR FROM invoice_date::DATE) = 2009);

-- сренднее значение длины фильмов с условиями
SELECT name, AVG(length)
  FROM category
           INNER JOIN film_category USING (category_id)
           INNER JOIN movie USING (film_id)
 WHERE rating = (SELECT rating
                   FROM movie
                  GROUP BY rating
                  ORDER BY AVG(rental_rate) DESC
                  LIMIT 1)
 GROUP BY name;