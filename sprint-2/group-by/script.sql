-- общая выручку в США
SELECT SUM(total)
  FROM invoice
 WHERE billing_country = 'USA';

-- общую выручку, заказы и средню выручку по городам
SELECT billing_city, SUM(total), COUNT(invoice_id), AVG(total)
  FROM invoice
 WHERE billing_country = 'USA'
 GROUP BY billing_city;

-- создать новое поле катеогрий и посчитать по категориям
SELECT CASE
           WHEN total < 1 THEN 'low cost'
           WHEN total >= 1 THEN 'high cost'
           END AS cost_category,
       SUM(total)
  FROM invoice
           JOIN client USING (customer_id)
 WHERE client.phone IS NOT NULL
 GROUP BY cost_category;

-- вывести актеров
SELECT category.name, COUNT(DISTINCT (film_actor.actor_id)) AS actor_count
  FROM category
           INNER JOIN film_category USING (category_id)
           INNER JOIN film_actor USING (film_id)
 GROUP BY category.name
 ORDER BY actor_count DESC, name;
