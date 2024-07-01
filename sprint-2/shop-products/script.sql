-- создание таблицы
CREATE TABLE IF NOT EXISTS store.products (
    PRIMARY KEY (id),
    id          SERIAL,
    name        VARCHAR(128)   NOT NULL,
    description VARCHAR(512),
    category    VARCHAR(128),
    price       NUMERIC(10, 2) NOT NULL,
    amount      INT2,
    created_at  TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at  TIMESTAMP
);

-- добавление данных в таблицу
INSERT INTO store.products (name, description, category, price, amount, created_at, deleted_at)
VALUES ('Кружка', 'Синяя гжель', 'Посуда', 229.99, 36, '2023-06-26 19:55:43', NULL);

-- получаение данных из таблицы
SELECT *
  FROM store.products;