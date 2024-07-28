-- create database
CREATE DATABASE crispy_celery;

-- create tables
CREATE TABLE products (
    PRIMARY KEY (id),
    id   SERIAL,
    name TEXT
);

CREATE TABLE conformity_certs (
    PRIMARY KEY (id),
    id         SERIAL,
    product_id INTEGER
        REFERENCES products,
    cert       JSONB
);

CREATE TABLE vendors (
    guid UUID NOT NULL,
    name TEXT,
    inn  TEXT
);

CREATE TABLE week_revenue (
    PRIMARY KEY (id),
    id         SERIAL,
    date_begin DATE,
    revenue    INTEGER ARRAY
);

CREATE TYPE ROOM_PROPERTIES AS (
    area          NUMERIC,
    floor         SMALLINT,
    cadastral_num TEXT,
    is_owned      BOOLEAN
);

CREATE TYPE SHOP_SERVICES AS ENUM ('доставка', 'самовывоз', 'без кассиров', 'кафе', 'свежевыжатые соки');

CREATE TABLE shops (
    PRIMARY KEY (id),
    id         SERIAL,
    address    TEXT,
    properties ROOM_PROPERTIES,
    services   SHOP_SERVICES ARRAY
);

CREATE TABLE storehouses (
    PRIMARY KEY (id),
    id         SERIAL,
    address    TEXT,
    properties ROOM_PROPERTIES
);

-- insert data
INSERT INTO products (id, name)
VALUES (1, 'миндальное молоко'),
       (2, 'сельдерей'),
       (3, 'смузи'),
       (4, 'омлет'),
       (5, 'матча');

INSERT INTO conformity_certs (id, product_id, cert)
VALUES (3, 2, '{
  "product_name": "сельдерей",
  "certifications": [
    {
      "date": "01.06.2023",
      "number": 123,
      "result": "very good"
    },
    {
      "date": "01.07.2023",
      "number": 456,
      "result": "good"
    },
    {
      "date": "01.08.2023",
      "number": 789,
      "result": "very good"
    }
  ]
}'),
       (2, 1, '{
         "signed": [
           "Яблочкин И.И.",
           "Коровкина А.Е.",
           "Водный С.Г."
         ],
         "cert_date": "01.09.2023",
         "cert_number": 12345,
         "product_name": "миндальное молоко"
       }');

INSERT INTO vendors (guid, name, inn)
VALUES ('a6171555-17ef-4a5b-90f0-610e706aa06f', 'ООО “Буренка”', '7777123456');

INSERT INTO week_revenue (id, date_begin, revenue)
VALUES (2, '2023-08-07', '{{115,81,96},{96,65,99},{105,71,103},{100,63,97},{140,97,103},{111,88,89},{105,84,101}}'),
       (4, '2023-08-21', '{{117,79,92},{99,66,99},{104,73,98},{103,65,98}}'),
       (5, '2023-08-28', '{{100,70,90},{90,60,90}}'),
       (1, '2023-08-14', '{{120,79,98},{98,60,101},{100,75,103},{101,68,93},{139,90,105},{130,81,87},{115,80,100}}');

INSERT INTO shops (id, address, properties, services)
VALUES (1, 'ул. Ландышевая 8', '(100,2,77:34:567890:12,t)', '{кафе,доставка,самовывоз}'),
       (2, 'Свежий пр-т 22', '(120,-1,00:34:567890:12,f)', '{кафе,доставка}');

INSERT INTO storehouses (id, address, properties)
VALUES (1, 'ул. Холодная 11', '(150,1,34:34:567890:12,f)'),
       (2, 'ул. Стеллажная 15', '(170,1,56:34:567890:12,t)'),
       (3, 'ул. Большая 14', '(150,1,,t)');

