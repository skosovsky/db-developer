-- получить значения
SELECT name, phone, email
  FROM suppliers;

-- выборка с условиями
SELECT name, category, description, price
  FROM products
 WHERE category = 'Модные аксессуары'
   AND description ILIKE '%синий%'
   AND amount > 0;

-- еще выборка с условиями
SELECT name, category, price, amount
  FROM products
 WHERE origin_country = 'Китай'
   AND (price < 1000 OR amount < 3);