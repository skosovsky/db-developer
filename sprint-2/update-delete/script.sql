-- найти фильмы с некорректным рейтингом
SELECT *
  FROM movie
           JOIN film_category ON movie.film_id = film_category.film_id
           JOIN category ON film_category.category_id = category.category_id
 WHERE movie.film_id = film_category.film_id
   AND category.name = 'Children'
   AND movie.rating = 'NC-17';

-- обновить некореетный рейтинг у фильмов
UPDATE movie
   SET rating = 'R'
  FROM film_category
           JOIN category ON film_category.category_id = category.category_id
 WHERE movie.film_id = film_category.film_id
   AND category.name = 'Children'
   AND movie.rating = 'NC-17';

-- найти фильмы Джони Кейджа
SELECT *
  FROM movie
           JOIN film_actor ON movie.film_id = film_actor.film_id
           JOIN actor ON actor.actor_id = film_actor.actor_id
 WHERE movie.film_id = film_actor.film_id
   AND actor.first_name = 'Johnny'
   AND actor.last_name = 'Cage';

-- обновить фильмы Джони Кейджа
UPDATE movie
   SET description = description || '. Actor Johnny Cage takes part in the film.'
  FROM film_actor
           JOIN actor ON actor.actor_id = film_actor.actor_id
 WHERE movie.film_id = film_actor.film_id
   AND actor.first_name = 'Johnny'
   AND actor.last_name = 'Cage';

-- найти продажи трека
SELECT *
  FROM invoice_line
           JOIN track ON invoice_line.track_id = track.track_id
 WHERE track.name = 'Balls to the Wall';

-- удалить эти продажи
DELETE
  FROM invoice_line
      USING track
 WHERE invoice_line.track_id = track.track_id
   AND track.name = 'Balls to the Wall';
