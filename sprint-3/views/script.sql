-- удаляем таблиц чтобы пересоздать
DROP TABLE IF EXISTS clients CASCADE;

-- создаем таблицу
CREATE TABLE clients (
    PRIMARY KEY (client_id),
    client_id SERIAL,                 -- уникальный идентификатор
    full_name CHARACTER VARYING(150), -- фамилия имя отчество пользователя
    phone     CHARACTER VARYING(15),  -- номер телефона пользователя
    address   CHARACTER VARYING(150), -- адрес пользователя
    login     CHARACTER VARYING(50),  -- логин пользователя
    password  CHARACTER VARYING(50)   -- пароль пользователя (обычно хешируют)
);

-- вставим данные
INSERT INTO clients (full_name, phone, address, login, password)
VALUES ('Иванов Иван Иванович', '79990000001',
        'г. Москва, Красная площадь, д. 1', 'IVANOV_II', 'tsartheterrible1530'),
       ('Петров Пётр Петрович', '79990000002',
        'г. Санкт-Петербург, Сенатская площадь, д. 1', 'PETROV_PP', 'piterthegreat1672'),
       ('Васильев Василий Васильевич', '79990000004',
        'г. Сочи, ул. Ленина, д. 1', 'VASILEV', 'vasiliytheblind2003');

-- создадим запрос
SELECT client_id,
       full_name,
       address,
       phone,
       'login: ' || login || '; password: ' || password AS login_password
  FROM clients
 WHERE full_name = 'Иванов Иван Иванович'
   AND phone = '79990000001';

-- сделаем представление
CREATE VIEW clients_ivanov AS
SELECT client_id,
       full_name,
       address,
       phone,
       'login: ' || login || '; password: ' || password AS login_password
  FROM clients
 WHERE full_name = 'Иванов Иван Иванович'
   AND phone = '79990000001';

-- сделаем запрос к представлению
SELECT client_id, login_password
  FROM clients_ivanov;

-- сделаем еще представления
CREATE OR REPLACE VIEW v_clients_user_info AS
SELECT client_id, full_name, phone
  FROM clients;

CREATE OR REPLACE VIEW v_clients_auth AS
SELECT login, password
  FROM clients;

-- перепопределим данные
CREATE OR REPLACE VIEW v_clients_user_info AS
SELECT client_id, full_name, phone, address, full_name || phone || address AS additional_field
  FROM clients;

-- создать представлениес с сотрудниками
CREATE OR REPLACE VIEW top_salesman AS
SELECT staff.last_name, staff.first_name, SUM(invoice.total)
  FROM staff
           INNER JOIN client ON support_rep_id = staff.employee_id
           INNER JOIN invoice USING (customer_id)
 GROUP BY staff.last_name, staff.first_name;
SELECT *
  FROM top_salesman;

-- создать представление с 1 столбцом
CREATE OR REPLACE VIEW happy_new_year AS
SELECT CONCAT((EXTRACT(YEAR FROM CURRENT_DATE) + 1), '-', '01', '-', '01')::DATE - CURRENT_DATE AS days;
SELECT days
  FROM happy_new_year;

-- изменить представление
DROP VIEW happy_new_year;
CREATE OR REPLACE VIEW happy_new_year AS
SELECT (CONCAT((EXTRACT(YEAR FROM CURRENT_DATE) + 1), '-', '01', '-', '01')::DATE - CURRENT_DATE) * '1 day'::INTERVAL AS days;
SELECT days
  FROM happy_new_year;

-- переименовать представление
    ALTER VIEW happy_new_year RENAME TO v_days_before_new_year;
SELECT days
  FROM v_days_before_new_year;