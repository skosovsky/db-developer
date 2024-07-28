-- подготовим данные
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    PRIMARY KEY (student_id),
    student_id    SERIAL,
    full_name     VARCHAR(300)  NOT NULL,
    phone         VARCHAR(20)   NOT NULL,
    address       VARCHAR(300)  NULL,
    average_scope NUMERIC(6, 2) NULL
);

INSERT INTO students(full_name, phone, address)
VALUES ('Медведев Александр Анатольевич', '+7(111)111-11-11', NULL),
       ('Картошкина Вера Олеговна', '+7(888)888-88-88', 'Новосибирск'),
       ('Котов Сергей Дмитриевич', '+7(777)777-77-77', 'Москва'),
       ('Зайцев Андрей Алексеевич', '+7(666)666-66-66', NULL),
       ('Туя Аркадий Эрнестович', '+7(555)555-55-55', 'Ялта'),
       ('Сишарпов Николай Анатольевич', '+7(444)444-44-44', NULL),
       ('Иванов Андрей Фёдорович', '+7(333)333-33-33', NULL);

CREATE TABLE payments (
    student_id INTEGER NOT NULL,
    payment_dt DATE    NOT NULL,
    amount     NUMERIC(9, 2)
);

INSERT INTO payments
SELECT student_id, CURRENT_DATE, 100000
  FROM students;

-- блокировка строк
BEGIN;
SELECT full_name, average_scope
  FROM students
 WHERE full_name IN ('Медведев Александр Анатольевич', 'Иванов Андрей Фёдорович')
     FOR NO KEY UPDATE;
UPDATE students
   SET average_scope = 5
 WHERE full_name IN ('Медведев Александр Анатольевич', 'Иванов Андрей Фёдорович');
COMMIT;

-- блокировка строк другой таблицы
BEGIN;

SELECT payments.*
  FROM students
           INNER JOIN payments USING (student_id)
 WHERE students.full_name = 'Медведев Александр Анатольевич'
     FOR NO KEY UPDATE OF payments;

-- блокировка таблицы
CREATE TABLE products (
    PRIMARY KEY (product_id),
    product_id SERIAL,
    name       VARCHAR(500)   NOT NULL,
    price      NUMERIC(15, 4) NOT NULL,
    unit       VARCHAR(10)    NOT NULL,
    quantity   INTEGER        NOT NULL DEFAULT 0
);
INSERT INTO products (name, price, unit, quantity)
VALUES ('Щебень гранитный фр. 2-5', 3700, 'тонна', 800),
       ('Щебень известняк фр. 20-40', 1800, 'тонна', 500),
       ('Керамзит фр.10/20', 1850, 'м3', 500),
       ('Песок речной', 2500, 'тонна', 900);

BEGIN;
LOCK TABLE products IN ACCESS EXCLUSIVE MODE;
COMMIT;

-- получение пид процесса
SELECT PG_BACKEND_PID();

-- проверка блокировки
SELECT pg_class.relname,
       pg_locks.pid,
       pg_locks.mode,
       pg_locks.granted,
       pg_locks.waitstart
  FROM pg_locks
           LEFT JOIN pg_class ON pg_class.oid = pg_locks.relation
 WHERE pg_class.relname = 'products'
   AND pg_locks.pid = 19854;

SELECT *
  FROM products
 WHERE name = 'Песок речной';

-- посмотреть блокировки
SELECT pg_class.relname,
       pg_locks.pid,
       pg_locks.mode,
       pg_locks.granted,
       pg_locks.waitstart,
       pg_blocking_pids(pg_locks.pid)
  FROM pg_locks
           LEFT JOIN pg_class ON pg_class.oid = pg_locks.relation
 WHERE pg_class.relname = 'products';

-- пример взаимной блокировки
CREATE TABLE balances (
    client_id INT,
    balance   NUMERIC(10, 2)
);

INSERT INTO balances
VALUES (1, 1000.00),
       (2, 200.00);

BEGIN;
UPDATE balances
   SET balance = balance - 100
 WHERE client_id = 1;

UPDATE balances
   SET balance = balance + 100
 WHERE client_id = 2;
COMMIT;

-- задание
CREATE TABLE orders (
    PRIMARY KEY (order_id),
    order_id       INT,
    client_id      INT                                 NOT NULL,
    amount         NUMERIC(10, 2)                      NOT NULL,
    delivery_price NUMERIC(10, 2)                      NOT NULL,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    state          VARCHAR(20)
);

INSERT INTO orders(order_id, client_id, amount, delivery_price, created_at, state)
VALUES (1, 5, 5000, 500, '2023-09-20', 'доставлен'),
       (2, 8, 15000, 0, '2023-09-25', 'доставляется'),
       (3, 5, 1000, 500, '2023-09-25', 'готов к доставке'),
       (4, 2, 2500, 500, '2023-09-26', 'готов к доставке'),
       (5, 3, 750, 0, '2023-09-27', 'готов к доставке'),
       (6, 7, 8955, 500, '2023-09-27', 'готов к доставке'),
       (7, 9, 900, 0, '2023-09-28', 'готов к доставке'),
       (8, 4, 7800, 500, '2023-09-29', 'сборка'),
       (9, 2, 500, 0, '2023-09-29', 'готов к доставке'),
       (10, 1, 1000, 500, '2023-09-30', 'готов к доставке'),
       (11, 10, 5400, 500, '2023-09-30', 'готов к доставке'),
       (12, 9, 3600, 500, '2023-09-30', 'готов к доставке'),
       (13, 4, 11200, 0, '2023-09-30', 'сборка');

BEGIN;
LOCK TABLE orders IN ACCESS EXCLUSIVE MODE;
SELECT *
  FROM orders
 WHERE amount < 1000;
COMMIT;

-- задание 2
BEGIN;
LOCK TABLE orders IN ACCESS SHARE MODE;
COMMIT;

-- задание 3
BEGIN;
SELECT *
  FROM orders
 WHERE client_id = 4
   AND state <> 'доставлен'
     FOR NO KEY UPDATE;
COMMIT;