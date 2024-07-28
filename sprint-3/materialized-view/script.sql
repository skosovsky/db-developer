-- создаем материализованное представление
CREATE MATERIALIZED VIEW tmp_clients_view AS
SELECT client_id, full_name, phone
  FROM clients;

SELECT *
  FROM tmp_clients_view
 ORDER BY client_id;

-- внесем изменения
INSERT INTO clients(full_name, phone)
VALUES ('Платонов Платон Платонович', '79990000003');

UPDATE clients
   SET full_name = 'Леонидов Леонид Леонидович',
       phone     = '79990000005'
 WHERE client_id = 1;

DELETE
  FROM clients
 WHERE client_id = 2;

-- проверяем изменения
SELECT *
  FROM tmp_clients_view
 ORDER BY client_id;

-- обновим данные
REFRESH MATERIALIZED VIEW tmp_clients_view;

-- тестовое задание
DROP TABLE IF EXISTS clients CASCADE;

CREATE TABLE IF NOT EXISTS clients (
    PRIMARY KEY (client_id),
    client_id SERIAL,
    full_name VARCHAR(150),
    phone     VARCHAR(15)
);

INSERT INTO clients (full_name, phone)
VALUES ('Иванов Иван Иванович', '79990000001'),
       ('Петров Петр Петрович', '79990000002'),
       ('Васильев Василий Васильевич', '79990000004');

CREATE MATERIALIZED VIEW tmp_client AS
SELECT client_id, full_name, phone
  FROM clients;

INSERT INTO clients (full_name, phone)
VALUES ('Сидоров Сидор Сидорович', '79990000003');

SELECT COUNT(*)
  FROM tmp_client;

-- мини-банк
DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS payments CASCADE;

CREATE TABLE IF NOT EXISTS clients (
    PRIMARY KEY (client_id),
    client_id SERIAL,
    full_name VARCHAR(150),
    phone     VARCHAR(15)
);

CREATE TABLE IF NOT EXISTS payments (
    PRIMARY KEY (payment_id),
    payment_id SERIAL,
    client_id  INTEGER
        REFERENCES clients (client_id),
    amount     NUMERIC(18, 2),
    created_at TIMESTAMPTZ
);

INSERT INTO clients(full_name, phone)
SELECT 'ФИО ' || generate_series     AS full_name,
       'Телефон ' || generate_series AS phone
  FROM GENERATE_SERIES(1, 1000);

INSERT INTO payments (client_id, amount, created_at)
SELECT client_id, amount, created_at
  FROM (SELECT 1 + (RANDOM() * 999)::INTEGER                     AS client_id,
               -50000 + (RANDOM() * 100000)::NUMERIC(18, 2)      AS amount,
               CURRENT_TIMESTAMP - '1 year'::INTERVAL * RANDOM() AS created_at
          FROM GENERATE_SERIES(1, 20000)) AS sample_data
 ORDER BY sample_data.created_at;

-- проверим данные
SELECT *, SUM(amount) OVER (PARTITION BY client_id ORDER BY created_at) AS account_balance
  FROM payments
 WHERE client_id = 1
 ORDER BY created_at;

-- создадим материализованное представление
CREATE MATERIALIZED VIEW client_account_balance_view AS
SELECT client_id, SUM(amount) AS account_balance
  FROM payments
 GROUP BY client_id
 ORDER BY client_id;

REFRESH MATERIALIZED VIEW client_account_balance_view;

-- разные отделы по разному используют представление
SELECT clients.*, client_account_balance_view.account_balance
  FROM clients
           INNER JOIN client_account_balance_view USING (client_id)
 WHERE client_account_balance_view.account_balance < -300000;

SELECT clients.*, client_account_balance_view.account_balance
  FROM clients
           INNER JOIN client_account_balance_view USING (client_id)
 WHERE client_account_balance_view.account_balance > 300000;

SELECT SUM(CASE WHEN account_balance > 0 THEN account_balance END) AS debit_balance,
       SUM(CASE WHEN account_balance < 0 THEN account_balance END) AS credit_balance,
       SUM(account_balance)                                        AS balance
  FROM client_account_balance_view;

-- данные по годам
CREATE MATERIALIZED VIEW total_year_income AS
SELECT EXTRACT(YEAR FROM invoice_date::DATE) AS year,
       SUM(total)::NUMERIC                   AS total_income
  FROM invoice
 GROUP BY year
 ORDER BY year;
SELECT *
  FROM total_year_income;

-- данные по тезкам
CREATE MATERIALIZED VIEW person_city_count AS
SELECT city, COUNT(*) AS person_count
  FROM namesakes
 GROUP BY city
 ORDER BY person_count DESC;

DROP MATERIALIZED VIEW namesakes_count;

-- Не удаляйте запрос SELECT.
SELECT *
  FROM person_city_count;