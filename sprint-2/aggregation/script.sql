-- посчитать фильмы
SELECT MIN(release_year), MAX(release_year), ROUND(AVG(release_year))
  FROM movie;

-- посчитать пропуску
SELECT COUNT(*) - COUNT(fax)
  FROM client;

-- посчитать стоимость приобретения видеотреков
SELECT SUM(track.unit_price)
  FROM track
           JOIN media_type
                USING (media_type_id)
 WHERE media_type.name = 'Protected MPEG-4 video file';

-- посчитать количество фильмов в катеогориях
SELECT COUNT(DISTINCT film_id)
  FROM film_category
           JOIN category USING (category_id)
 WHERE name LIKE 'C%';

-- посчитать количество альбомов
SELECT COUNT(DISTINCT (album_id))
  FROM track
           JOIN genre USING (genre_id)
 WHERE genre.name LIKE ('Jazz');

-- посчитайте выручку
SELECT SUM(total),
       COUNT(DISTINCT (customer_id)),
       SUM(total) / COUNT(DISTINCT (customer_id)) AS sum_by_customer
  FROM invoice
 WHERE billing_country = 'USA';
