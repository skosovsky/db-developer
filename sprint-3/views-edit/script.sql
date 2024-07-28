-- удаляем старые таблицы
DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS addresses CASCADE;

-- создаем таблицы
CREATE TABLE IF NOT EXISTS addresses (
    PRIMARY KEY (address_id),
    address_id SERIAL, -- уникальный идентификатор
    location   CHARACTER VARYING(150)
);

CREATE TABLE IF NOT EXISTS clients (
    PRIMARY KEY (client_id),
    client_id  SERIAL,                     -- уникальный идентификатор
    full_name  CHARACTER VARYING(150),     -- ФИО клиента
    phone      CHARACTER VARYING(15),      -- номер телефона клиента
    address_id INTEGER
        REFERENCES addresses (address_id), -- id адреса клиента
    login      CHARACTER VARYING(50),      -- логин клиента
    password   CHARACTER VARYING(50)       -- пароль клиента
);

-- вставляем данные
INSERT INTO addresses (location)
VALUES ('г. Москва, Красная площадь, д. 1'),
       ('г. Санкт-Петербург, Сенатская площадь, д. 1'),
       ('г. Сочи, ул. Ленина, д. 1');

INSERT INTO clients (full_name, phone, address_id, login, password)
VALUES ('Иванов Иван Иванович', '79990000001', 1, 'IVANOV_II', 'tsartheterrible1530'),
       ('Петров Пётр Петрович', '79990000002', 2, 'PETROV_PP', 'piterthegreat1672'),
       ('Васильев Василий Васильевич', '79990000004', 3, 'VASILEV_VV', 'vasiliytheblind2003');

-- создаем представления
CREATE OR REPLACE VIEW clients_user_info_view AS
SELECT client_id, full_name, phone, address_id
  FROM clients;

CREATE OR REPLACE VIEW clients_auth_view AS
SELECT client_id, login, password
  FROM clients;

-- вставим, обновим, удалим данныпе в представлении
INSERT INTO clients_user_info_view (full_name, phone, address_id)
VALUES ('Иванов Федор Петрович', '79012344444', 1);

UPDATE clients_user_info_view
   SET full_name = 'Козлов Федор Петрович',
       phone     = NULL
 WHERE full_name = 'Иванов Федор Петрович';

DELETE
  FROM clients_user_info_view
 WHERE phone IS NULL;

INSERT INTO clients_auth_view (login, password)
VALUES ('ivanov_ii', 123);

UPDATE clients_auth_view
   SET password = '111'
 WHERE login = 'ivanov_ii';

DELETE
  FROM clients_auth_view
 WHERE password = '111';