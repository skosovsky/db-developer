-- создадим таблицы
CREATE TABLE accounts (
    PRIMARY KEY (account_id),
    account_id     SERIAL,
    number         VARCHAR(255)   NOT NULL,
    balance        NUMERIC(12, 2) NOT NULL
        CHECK (balance >= 0),
    last_update_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO accounts (number, balance, last_update_at)
VALUES ('BG22UBBS890', 5000.00, '2023-05-28 00:00:00'),
       ('BG79UBBS901', 3000.00, '2023-05-21 00:00:00'),
       ('BG31UBBS012', 15000.00, '2023-05-22 00:00:00');

CREATE TABLE account_transactions (
    PRIMARY KEY (transaction_id),
    transaction_id SERIAL,
    account_id     INTEGER
        REFERENCES accounts,
    amount         NUMERIC(12, 2) NOT NULL
        CHECK (amount > 0),
    type           CHAR(1)        NOT NULL,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO account_transactions (account_id, amount, type, created_at)
VALUES (1, 1000.00, 'D', '2023-05-30 00:00:00'),
       (1, 500.00, 'W', '2023-05-29 00:00:00'),
       (2, 1500.00, 'D', '2023-05-31 00:00:00'),
       (3, 5000.00, 'W', '2023-05-30 00:00:00');

-- транзакция
BEGIN;
UPDATE accounts
   SET balance        = balance - 500,
       last_update_at = CURRENT_TIMESTAMP
 WHERE number = 'BG22UBBS890';

UPDATE accounts
   SET balance        = balance + 500,
       last_update_at = CURRENT_TIMESTAMP
 WHERE number = 'BG31UBBS012';

INSERT INTO account_transactions (account_id, amount, type)
VALUES (8, 500, 'W');

INSERT INTO account_transactions (account_id, amount, type)
VALUES (3, 500, 'D');
COMMIT;

ROLLBACK;

-- задание
CREATE TABLE household_products (
    PRIMARY KEY (product_id),
    product_id  INTEGER,
    description VARCHAR(255)                        NOT NULL,
    amount      SMALLINT                            NOT NULL,
    modify_dt   TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

INSERT INTO household_products (product_id, description, amount, modify_dt)
VALUES (1, 'Тостер', 10, '2023-06-09 10:00:00'),
       (2, 'Микроволновая печь', 5, '2023-06-09 11:30:00'),
       (3, 'Кофеварка', 15, '2023-06-09 12:45:00'),
       (4, 'Пылесос', 8, '2023-06-09 09:15:00'),
       (5, 'Утюг', 12, '2023-06-09 13:20:00');

BEGIN;
INSERT INTO household_products (product_id, description, amount)
VALUES (9, 'Электрочайник', 11);
INSERT INTO household_products (product_id, description, amount)
VALUES (10, 'Хлебопечка', 4);
INSERT INTO household_products (product_id, description, amount)
VALUES (1, 'Пылесос ручной', 3);
INSERT INTO household_products (product_id, description, amount)
VALUES (2, 'Мясорубка', 8);
INSERT INTO household_products (product_id, description, amount)
VALUES (13, 'Соковыжималка', 6);
INSERT INTO household_products (product_id, description, amount)
VALUES (14, 'Кофемолка', 9);
COMMIT;
ROLLBACK;

BEGIN;

INSERT INTO household_products (product_id, description, amount)
VALUES (9, 'Электрочайник', 11);

INSERT INTO household_products (product_id, description, amount)
VALUES (10, 'Хлебопечка', 4);

SAVEPOINT product_1;

INSERT INTO household_products (product_id, description, amount)
VALUES (1, 'Пылесос ручной', 3);

INSERT INTO household_products (product_id, description, amount)
VALUES (2, 'Мясорубка', 8);

ROLLBACK TO SAVEPOINT product_1;

INSERT INTO household_products (product_id, description, amount)
VALUES (13, 'Соковыжималка', 6);

INSERT INTO household_products (product_id, description, amount)
VALUES (14, 'Кофемолка', 9);

COMMIT;

-- проверка
SELECT CAST(EXTRACT(EPOCH FROM (MAX(modify_dt) - MIN(modify_dt))) AS INT) AS diff
  FROM household_products
 WHERE product_id > 5;

SELECT COUNT(*)
  FROM household_products;

-- транзакции с уровнями
DROP TABLE IF EXISTS products CASCADE;

CREATE TABLE products (
    name  VARCHAR(50),
    price NUMERIC(10, 2)
);

INSERT INTO products (name, price)
VALUES ('Product 1', 12.50),
       ('Product 2', 10.40),
       ('Product 3', 7.99),
       ('Product 4', 14.99);

-- READ COMMITTED
BEGIN;

SHOW transaction_isolation;
SELECT MAX(price)
  FROM products;

INSERT INTO products (name, price)
VALUES ('Product 5', 50.40);

SELECT MAX(price)
  FROM products;

COMMIT;

-- REPEATABLE READ
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SHOW transaction_isolation;
SELECT MAX(price)
  FROM products;

BEGIN;
UPDATE products
   SET price = 100.00
 WHERE name = 'Product 5';
COMMIT;

-- аномалия сериализации
CREATE TABLE warehouse_movements (
    PRIMARY KEY (movement_id),
    movement_id SERIAL,
    store_id    INTEGER,
    product_id  CHAR(5),
    quantity    INTEGER,
    update_dt   TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_actual   BOOLEAN                     DEFAULT TRUE
);

INSERT INTO warehouse_movements (store_id, product_id, quantity)
VALUES (1, 'A', 100),
       (1, 'B', 100),
       (2, 'A', 200),
       (2, 'B', 200);

--
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
INSERT INTO warehouse_movements (store_id, product_id, quantity)
SELECT 2, 'C', qnt
  FROM (SELECT SUM(quantity) AS qnt
          FROM warehouse_movements
         WHERE store_id = 1) AS sum_qnt;

UPDATE warehouse_movements
   SET is_actual = FALSE
 WHERE store_id = 1;
COMMIT;

-- задание
CREATE TABLE users (
    PRIMARY KEY (user_id),
    user_id INTEGER,
    name    VARCHAR(50),
    balance NUMERIC(10, 2)
);
CREATE TABLE operations (
    PRIMARY KEY (operation_id),
    operation_id SERIAL,
    user_id      INTEGER
        REFERENCES users,
    amount       NUMERIC(10, 2)
);
INSERT INTO users (user_id, name, balance)
VALUES (1, 'User 1', 100.00),
       (2, 'User 2', 200.00),
       (3, 'User 3', 300.00),
       (4, 'User 4', 400.00),
       (5, 'User 5', 500.00);
INSERT INTO operations (user_id, amount)
VALUES (1, 550.00),
       (2, 100.00),
       (2, 200.00),
       (3, 150.00),
       (4, 200.00),
       (4, 50.00),
       (5, 250.00);

-- расчитать итоговый баланс
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
UPDATE users
   SET balance = current_balance.balance
  FROM (SELECT user_id, balance + SUM(operations.amount) AS balance
          FROM users
                   INNER JOIN operations USING (user_id)
         GROUP BY user_id, balance) AS current_balance
 WHERE users.user_id = current_balance.user_id;

UPDATE users
   SET balance = balance * 1.1
 WHERE user_id BETWEEN 1 AND 7;
COMMIT;

INSERT INTO users (user_id, name, balance)
VALUES (6, 'User 6', 100);
INSERT INTO operations (user_id, amount)
VALUES (6, 100.00),
       (6, 200.00);

INSERT INTO users (user_id, name, balance)
VALUES (7, 'User 7', 700);

--
UPDATE users
   SET balance = balance + sum_operations
  FROM (SELECT user_id, SUM(amount) AS sum_operations
          FROM operations
         GROUP BY user_id) AS operations_balance
 WHERE users.user_id = operations_balance.user_id;