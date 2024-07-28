-- среднее от среднего
SELECT AVG(best_rating.average_rental)
  FROM (SELECT rating, AVG(rental_rate) AS average_rental
          FROM movie
         GROUP BY rating
         ORDER BY average_rental DESC
         LIMIT 5) AS best_rating;

-- посчитаем в скольких фильмах снимались лучшие актеры
SELECT SUM(total_movie)
  FROM (SELECT first_name, last_name, COUNT(film_id) AS total_movie
          FROM actor
                   LEFT JOIN film_actor USING (actor_id)
                   LEFT JOIN movie USING (film_id)
         GROUP BY first_name, last_name
         ORDER BY total_movie DESC
         LIMIT 3) AS top_actor;

-- найти 40 самых длинных фильмов, не дороже 2 долларов
SELECT title, rental_rate, length, rating
  FROM movie
 WHERE rental_rate > 2
 ORDER BY length DESC
 LIMIT 40;

-- выведите ретинг и стоимость по рейтингу
SELECT rating,
       MIN(longest_movies.length)      AS min_length,
       MAX(longest_movies.length)      AS max_length,
       AVG(longest_movies.length)      AS avg_length,
       MIN(longest_movies.rental_rate) AS min_rental_rate,
       MAX(longest_movies.rental_rate) AS max_rental_rate,
       AVG(longest_movies.rental_rate) AS avg_rental_rate
  FROM (SELECT rental_rate, length, rating
          FROM movie
         WHERE rental_rate > 2
         ORDER BY length DESC
         LIMIT 40) AS longest_movies
 GROUP BY rating
 ORDER BY avg_length;

-- найдите средние значения полей
SELECT AVG(statistics.min_length) AS avg_min_length, AVG(statistics.max_length) AS avg_max_length
  FROM (SELECT MIN(top.length) AS min_length,
               MAX(top.length) AS max_length,
               AVG(top.length) AS avg_length
          FROM (SELECT length,
                       rating
                  FROM movie
                 WHERE rental_rate > 2
                 ORDER BY length DESC
                 LIMIT 40) AS top
         GROUP BY top.rating
         ORDER BY avg_length) AS statistics;

-- найдите рок-альбомы с > 8 треками, выведите их среднее количество
SELECT AVG(count_tracks)
  FROM (SELECT COUNT(track.track_id) AS count_tracks
          FROM album
                   INNER JOIN track USING (album_id)
         WHERE title ILIKE '%rock%'
         GROUP BY title
        HAVING COUNT(track.track_id) >= 8) AS rock_albums;