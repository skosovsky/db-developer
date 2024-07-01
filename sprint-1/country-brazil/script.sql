-- выгрузить всех кто живет в Бразилии
SELECT first_name,
       last_name,
       city
  FROM client
 WHERE country = 'Brazil';