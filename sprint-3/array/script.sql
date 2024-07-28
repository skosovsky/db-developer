-- создадим таблицу с массивом
CREATE TABLE clients (
    PRIMARY KEY (client_id),
    client_id  INTEGER,
    name       TEXT,
    phone      TEXT,
    add_phones TEXT[]
);

-- вставим данные
INSERT INTO clients(client_id, name, phone, add_phones)
VALUES (1, 'Лесной Анатолий Игоревич', '71112223344', '{"78885556677", "7333556677"}');

-- или так
INSERT INTO clients(client_id, name, phone, add_phones)
VALUES (2, 'Лесной Анатолий Игоревич', '71112223344', ARRAY ['78885556677','7333556677']);

-- читаем
SELECT add_phones[1]
  FROM clients
 WHERE client_id = 1;

-- двумерный
CREATE TABLE depots_economic_report (
    PRIMARY KEY (report_id),
    report_id     INTEGER,
    depot_id      INTEGER,
    begin_dt      DATE,
    economic_data INTEGER[7][2]
);

-- вставим данные
INSERT INTO depots_economic_report(report_id, depot_id, begin_dt, economic_data)
VALUES (1, 1, CURRENT_DATE, '{{100,40},{200,85}}');

-- или так
INSERT INTO depots_economic_report(report_id, depot_id, begin_dt, economic_data)
VALUES (2, 1, CURRENT_DATE, ARRAY [[100,40],[200,85]]);

-- читаем
SELECT economic_data[1][1]
  FROM depots_economic_report
 WHERE report_id = 1;

-- многомерный
CREATE TABLE array_tests (
    arr_data INTEGER[]
);

INSERT INTO array_tests(arr_data)
VALUES ('{{{1, 2}, {3, 4}}, {{5, 6}, {7, 8}}}');

SELECT arr_data[2][1][2]
  FROM array_tests;

-- изменяем массив
UPDATE clients
   SET add_phones = add_phones || '{"75553334455"}'
 WHERE phone = '71112223344';

UPDATE clients
   SET add_phones = '{"75553334455"}' || add_phones
 WHERE phone = '71112223344';

UPDATE clients
   SET add_phones = ARRAY_APPEND(add_phones, '7111223345')
 WHERE phone = '71112223344';

-- или заменить значение
UPDATE depots_economic_report
   SET economic_data[1][2] = 50
 WHERE report_id = 1;

-- или несколько значения
UPDATE clients
   SET add_phones[1:2] = '{"01", "02"}'
 WHERE phone = '71112223344';

-- поиск значения
SELECT *
  FROM clients
 WHERE '7333556677' = ANY (add_phones);

-- поиск значение через сравнение массивов
SELECT *
  FROM clients
 WHERE add_phones && '{"7333556677"}';

-- поиск значения по всем элементам
SELECT *
  FROM depots_economic_report
 WHERE 40 < ALL (economic_data);

-- для поиска по двумерному массиву, ищем по среду
SELECT COUNT(*)
  FROM week_revenue
 WHERE 140 <= ANY (revenue);

-- сравним массивы
SELECT ARRAY [1, 2, 3] = ARRAY [1, 2, 3];

-- проверим вхождение в массивы
SELECT ARRAY [1,2,3,4,5] @> ARRAY [5,3]; -- true
SELECT ARRAY [1,2,3,4,5] <@ ARRAY [5,3];
-- false

-- длина массива
SELECT ARRAY_LENGTH(ARRAY [1,2,3], 1);
SELECT ARRAY_LENGTH(ARRAY [[1, 2, 3], [4, 5, 6]], 1);

SELECT *, ARRAY_LENGTH(add_phones, 1)
  FROM clients;

SELECT *, ARRAY_LENGTH(economic_data, 1)
  FROM depots_economic_report;

-- переводим массив в строку
SELECT ARRAY_TO_STRING(add_phones, ', ')
  FROM clients
 WHERE client_id = 1;

-- или в json
SELECT ARRAY_TO_JSON(add_phones)
  FROM clients
 WHERE client_id = 1;

-- строку вмассив
UPDATE clients
   SET add_phones = STRING_TO_ARRAY('72228880000, 78885550000', ', ')
 WHERE client_id = 1;

-- UNNEST
CREATE TABLE drivers_schedule (
    PRIMARY KEY (driver_id),
    driver_id   SERIAL,
    schedule_dt DATE,
    depot_id    INTEGER,
    driver_guid UUID
);

INSERT INTO drivers_schedule(depot_id, driver_guid)
SELECT 1,
       UNNEST(ARRAY [
           '189ec08d-af9c-4f7f-a65c-d12c460d19eb',
           'b9c2e818-bdbb-4cea-bd65-5f3b42782d80',
           'cbdfac9f-5d95-4fbd-a081-11bddcf56dd5'
           ])::UUID;