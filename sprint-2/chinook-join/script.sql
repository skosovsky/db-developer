-- соединяем актеров и категории
SELECT DISTINCT name
  FROM category
           JOIN film_category
                ON category.category_id = film_category.category_id
           JOIN film_actor
                ON film_category.film_id = film_actor.film_id
           JOIN actor
                ON film_actor.actor_id = actor.actor_id
 WHERE first_name = 'Emily'
   AND last_name = 'Dee';

-- соединяем менеджеров и сотрудников (из одной таблицы)
SELECT employee.last_name AS employee_last_name,
       manager.last_name  AS manager_last_name
  FROM staff AS employee
           LEFT JOIN staff AS manager
                     ON employee.reports_to = manager.employee_id;

-- треки и их стоимость
SELECT track.name,
       CAST(invoice.invoice_date AS DATE)
  FROM track
           LEFT JOIN invoice_line
                     USING (track_id)
           LEFT JOIN invoice
                     USING (invoice_id);

-- фильмы, по актером и актрисам не указанным в базе
SELECT title
  FROM movie
           LEFT JOIN film_actor
                     USING (film_id)
 WHERE actor_id IS NULL;
