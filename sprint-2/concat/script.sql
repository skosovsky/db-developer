-- объединение с NULL
SELECT billing_city,
       billing_state,
       billing_country,
       CONCAT(billing_city, ' ', billing_state, ' ', billing_country) AS concat_data
  FROM invoice
 LIMIT 5;

-- разделение на части
SELECT SPLIT_PART('Петров Александр Александрович', ' ', 1)  AS surname,
       SPLIT_PART('Петров Александр Александрович', ' ', -2) AS name;

-- выделяем по длине
SELECT SUBSTR('Петров Александр Александрович', 8)    AS first_and_middle_name,
       SUBSTR('Петров Александр Александрович', 8, 9) AS first_name;

-- найти подстроку
SELECT STRPOS('Петров Александр Александрович', 'Александр') AS name_position;

-- создать временную таблицу и найти номера заказов
CREATE TEMPORARY TABLE orders_example (
    PRIMARY KEY (id),
    id         SERIAL,
    order_info VARCHAR(256)
);

INSERT INTO orders_example (order_info)
VALUES ('Фанера ФК 15 мм, 5 листов, заказ №3547 от 25.07.2023'),
       ('Брусок строганный, 5х5, 5 шт, заказ №0008857 от 26.07.2023');

SELECT order_info,
       LTRIM(SPLIT_PART(SUBSTR(order_info, STRPOS(order_info, '№') + 1), ' ', 1), '№0') AS order_id
  FROM orders_example;

-- посчитать количество альбомов, в названии больше 10 символов
SELECT COUNT(title)
  FROM album
 WHERE LENGTH(title) > 10;

-- создание новой строки
SELECT CONCAT(INITCAP(first_name), ' ', INITCAP(last_name), ', ',
              address, ', ', city, ', ',
              state, ' ', postal_code, ', ',
              UPPER(country)) AS post_address
  FROM staff;

-- вывединте уникальные занчения доменов
SELECT DISTINCT(SUBSTR(email, STRPOS(email, '@') + 1))
  FROM client;

-- перечислите названия фильмов
SELECT name,
       STRING_AGG(movie.title, ', ' ORDER BY movie.title)
  FROM category
           INNER JOIN film_category USING (category_id)
           INNER JOIN movie USING (film_id)
 GROUP BY name;
