-- сравнить фильмы разных рейтингов
SELECT rating, AVG(rental_rate)
  FROM movie
 GROUP BY rating
HAVING AVG(rental_rate) > 3;

-- сравнить выручку
SELECT CAST(invoice_date AS DATE), SUM(total)
  FROM invoice
 WHERE invoice_date BETWEEN '2011-09-01' AND '2011-09-30'
 GROUP BY invoice_date
HAVING SUM(total) BETWEEN 1 AND 10;

-- посчитать пропуски индексов
SELECT billing_country, COUNT(*) - COUNT(billing_postal_code)
  FROM invoice
 WHERE billing_address <> '%Street%'
   AND billing_address <> '%Way%'
   AND billing_address <> '%Road%'
   AND billing_address <> '%Drive%'
 GROUP BY billing_country
HAVING COUNT(*) - COUNT(billing_postal_code) > 10;

-- вывести альбомы, где треки меньше 5 долларов
SELECT title, SUM(track.unit_price) AS album_price
  FROM album
           INNER JOIN track USING (album_id)
 GROUP BY title
HAVING SUM(track.unit_price) < 5
 ORDER BY album_price DESC;

-- вывести повторяющиеся имена
SELECT DISTINCT(first_name), COUNT(first_name)
  FROM client
 GROUP BY first_name
HAVING COUNT(first_name) > 1;
