-- вывести товар с сортировкой и условиями
SELECT name, description, origin_country, price
  FROM products
 WHERE category = 'Модные аксессуары'
   AND amount > 0
 ORDER BY price DESC;

-- вывести товары с пагинацией
SELECT name, description, origin_country, price
  FROM products
 WHERE category = 'Модные аксессуары'
   AND amount > 0
 ORDER BY price DESC
OFFSET 10 LIMIT 5;

-- с удалением дубликатов
SELECT DISTINCT origin_country
  FROM products
 WHERE amount > 0
 ORDER BY origin_country ASC;

-- и указанием минимальной цены
SELECT DISTINCT ON (origin_country) origin_country, price
  FROM products
 WHERE amount > 0
 ORDER BY origin_country ASC, price ASC;