-- удалим таблицы
DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS purchases CASCADE;
DROP TABLE IF EXISTS products CASCADE;

-- создадим таблицу о покупателях
CREATE TABLE IF NOT EXISTS clients (
    PRIMARY KEY (id),
    id      SERIAL,
    name    VARCHAR(20) NOT NULL,
    surname VARCHAR(40) NOT NULL,
    phone   VARCHAR(40)
);

-- создадим таблицу о товарах
CREATE TABLE products (
    PRIMARY KEY (id),
    id   SERIAL,
    name VARCHAR(40) NOT NULL,
    type VARCHAR(40) NOT NULL
);

-- создадим таблицу продаж
CREATE TABLE IF NOT EXISTS purchases (
    PRIMARY KEY (id),
    id              SERIAL,
    client_id       INTEGER
        REFERENCES clients (id),
    product_id      INTEGER
        REFERENCES products (id),
    date            TIMESTAMPTZ,
    billing_city    VARCHAR(40),
    billing_country VARCHAR(40),
    total           NUMERIC(10, 2) NOT NULL
);

-- добавим данные
INSERT INTO clients (name, surname, phone)
VALUES ('Роберт', 'Иванов', '654-42-18'),
       ('Антон', 'Иванов', '664-42-28'),
       ('Роберт', 'Земекис', NULL),
       ('Антон', 'Земекис', '234-55-91'),
       ('Роберт', 'Сергеев', NULL),
       ('Сергей', 'Сергеев', '321-55-91');

INSERT INTO products (name, type)
VALUES ('Азбука', 'Книга'),
       ('SQL-тренажёр', 'Программа'),
       ('Звуки природы', 'Аудиотрек');

INSERT INTO purchases(client_id, product_id, date, billing_city, billing_country, total)
VALUES (1, 1, '2023-05-01 12:00:00', 'Париж', 'Франция', 100.1),
       (1, 2, '2023-05-23 12:00:00', 'Москва', 'Россия', 200.2),
       (1, 3, '2023-05-24 13:00:00', 'Москва', 'Россия', 300.3),
       (2, 1, '2023-05-23 12:00:00', 'Париж', 'Франция', 10.1),
       (3, 2, '2023-05-23 15:00:00', 'Москва', 'Россия', 44.44),
       (3, 3, '2023-05-23 16:00:00', 'Париж', 'Франция', 55.55),
       (4, 1, '2023-05-23 00:00:00', 'Москва', 'Россия', 66.66),
       (4, 2, '2023-05-23 23:59:59', 'Москва', 'Россия', 77.77),
       (5, 3, '2023-05-23 12:00:00', 'Пекин', 'Китай', 88.88),
       (5, 1, '2023-06-01 12:00:00', 'Пекин', 'Китай', 99.99);

-- запрос с JOIN
SELECT purchases.*
  FROM purchases
           JOIN clients ON (purchases.client_id = clients.id)
 WHERE ((clients.name = 'Роберт' AND clients.surname = 'Иванов')
     OR (clients.name = 'Антон' AND clients.surname = 'Земекис'))
   AND purchases.date >= '2023-05-23'
   AND purchases.date < '2023-05-24';

-- запрос с WHERE
SELECT purchases.*
  FROM purchases,
       clients
 WHERE purchases.client_id = clients.id
   AND ((clients.name = 'Роберт' AND clients.surname = 'Иванов')
     OR (clients.name = 'Антон' AND clients.surname = 'Земекис'))
   AND purchases.date >= '2023-05-23'
   AND purchases.date < '2023-05-24';

-- обновим данные
   UPDATE purchases
      SET billing_city    = 'Стамбул',
          billing_country = 'Турция'
     FROM clients
    WHERE purchases.client_id = clients.id
      AND ((clients.name = 'Роберт' AND clients.surname = 'Иванов')
        OR (clients.name = 'Антон' AND clients.surname = 'Земекис'))
      AND purchases.date >= '2023-05-23'
      AND purchases.date < '2023-05-24'
RETURNING purchases.*;

-- другой запрос с JOIN
SELECT clients.*
  FROM clients
           JOIN purchases ON (purchases.client_id = clients.id)
           JOIN products ON (products.id = purchases.product_id)
 WHERE products.name = 'Азбука'
   AND purchases.date >= '2023-06-01'
   AND purchases.date < '2023-07-01'
   AND clients.phone IS NULL;

-- этот же запрос без JOIN
SELECT clients.*
  FROM clients,
       purchases,
       products
 WHERE purchases.client_id = clients.id
   AND products.id = purchases.product_id
   AND products.name = 'Азбука'
   AND purchases.date >= '2023-06-01'
   AND purchases.date < '2023-07-01'
   AND clients.phone IS NULL;

-- обновим данные
   UPDATE clients
      SET phone = '112-83-75'
     FROM purchases
              JOIN products ON products.id = purchases.product_id
    WHERE purchases.client_id = clients.id
      AND products.name = 'Азбука'
      AND purchases.date >= '2023-06-01'
      AND purchases.date < '2023-07-01'
      AND clients.phone IS NULL
RETURNING clients.*;