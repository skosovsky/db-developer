-- изменить значения
UPDATE products
   SET origin_country = 'Китай'
 WHERE code IN ('BWC457030456', 'BWC450980456');

-- изменить 2 значения
UPDATE suppliers
   SET bank_name    = 'Банк «Котикофф»',
       bank_account = '4180566789764'
 WHERE name = 'ОАО “Простор фантазии“';

-- удаление значения
DELETE
  FROM products
 WHERE price IS NULL;

-- очистка таблицы со сбросом автоинкремента
TRUNCATE TABLE orders RESTART IDENTITY;