-- создаем базу данных
CREATE DATABASE choo_gruz;

-- создаем 3 родительских таблицы
CREATE TABLE clients (
    PRIMARY KEY (id),
    id    INTEGER,
    name  TEXT,
    phone TEXT
);

CREATE TABLE speeds (
    PRIMARY KEY (id),
    id    INTEGER,
    type  TEXT,
    coeff NUMERIC(2, 1)
);

CREATE TABLE stations (
    PRIMARY KEY (id),
    id           INTEGER,
    station_code INTEGER,
    station_name TEXT,
    station_rw   TEXT
);

-- создаем 3 дочерних таблицы с внешними ключами
CREATE TABLE shipments (
    PRIMARY KEY (id),
    id          INTEGER,
    datetime    TIMESTAMP,
    freight     TEXT,
    sender_id   INTEGER
        REFERENCES clients,
    receiver_id INTEGER
        REFERENCES clients,
    speed_id    INTEGER
        REFERENCES speeds
);

CREATE TABLE clients_discounts (
    PRIMARY KEY (id),
    id        INTEGER,
    client_id INTEGER
        REFERENCES clients
        UNIQUE,
    discount  NUMERIC
);

CREATE TABLE routes (
    PRIMARY KEY (id),
    id           INTEGER,
    shipment_id  INTEGER
        REFERENCES shipments,
    station_id   INTEGER
        REFERENCES stations,
    date_arrival DATE
);

-- добавляем данные
INSERT INTO clients (id, name, phone)
VALUES (1, 'Кузнецов Игорь Николаевич', 79112223344),
       (2, 'ООО “Ручки-попрыгучки”', 79225556677),
       (3, 'Кузнецов Николай Петрович', 79441112233),
       (4, 'ООО “Всем по принтеру”', 79338889900),
       (5, 'ООО “Волнующий тюльпан”', 79554445566);

INSERT INTO speeds (id, type, coeff)
VALUES (1, 'Грузовая', 1),
       (2, 'Пассажирская', 1.6),
       (3, 'Большая', 2.1);

INSERT INTO shipments (id, datetime, freight, sender_id, receiver_id, speed_id)
VALUES (1, TO_TIMESTAMP('10.05.2023 17:10:00', 'dd.mm.yyyy hh24:mi:ss'), 'Личные вещи', 1, 3, 1),
       (2, TO_TIMESTAMP('12.05.2023 11:30:00', 'dd.mm.yyyy hh24:mi:ss'), 'Канцтовары', 2, 4, 1),
       (3, TO_TIMESTAMP('24.05.2023 09:00:00', 'dd.mm.yyyy hh24:mi:ss'), 'Упаковочные материалы', 4, 5, 3);

INSERT INTO clients_discounts (id, client_id, discount)
VALUES (1, 4, 5.0);

INSERT INTO stations (id, station_code, station_name, station_rw)
VALUES (1, 11111, 'Лапочкинск', 'Октябрьская ЖД'),
       (2, 22222, 'Радужный город', 'Октябрьская ЖД'),
       (3, 33333, 'Морковный хутор', 'Московская ЖД'),
       (4, 44444, 'Городищево', 'Московская ЖД'),
       (5, 55555, 'Береговское', 'Московская ЖД');

INSERT INTO routes (id, shipment_id, station_id, date_arrival)
VALUES (1, 1, 2, TO_DATE('10.05.2023', 'dd.mm.yyyy')),
       (2, 1, 3, TO_DATE('13.05.2023', 'dd.mm.yyyy')),
       (3, 3, 3, TO_DATE('24.05.2023', 'dd.mm.yyyy')),
       (4, 3, 5, TO_DATE('26.05.2023', 'dd.mm.yyyy')),
       (5, 2, 5, TO_DATE('12.05.2023', 'dd.mm.yyyy'));

-- проверим что не корректные значения не вставляются
INSERT INTO clients_discounts (id, client_id, discount)
VALUES (2, 100, 10.0);

-- проверим удаление строк с ограничением внешнего ключа
DELETE
  FROM stations
 WHERE id = 3;

-- изменим поведение ключа на CASCADE
-- удаляем внешний ключ
ALTER TABLE routes
    DROP CONSTRAINT routes_station_id_fkey;
-- добавим новый внешний ключ с ON DELETE CASCADE
ALTER TABLE routes
    ADD FOREIGN KEY (station_id) REFERENCES stations ON DELETE CASCADE;
-- опять попробуем удалить строку из stations
DELETE
  FROM stations
 WHERE id = 3;
-- проверим
SELECT *
  FROM routes;

-- изменим поведение ключа на RESTRICT
-- удаляем внешний ключ
ALTER TABLE routes
    DROP CONSTRAINT routes_station_id_fkey;
-- добавим новый внешний ключ с ON DELETE RESTRICT
ALTER TABLE routes
    ADD FOREIGN KEY (station_id) REFERENCES stations ON DELETE RESTRICT;
-- опять попробуем удалить строку из stations
DELETE
  FROM stations
 WHERE id = 2;
-- теперь удалим строку, на которую не ссылается дочерняя таблица
DELETE
  FROM stations
 WHERE id = 1;
-- проверим
SELECT *
  FROM stations
 WHERE id = 1;
-- вернем как было - удаляем внешний ключ
ALTER TABLE routes
    DROP CONSTRAINT routes_station_id_fkey;
ALTER TABLE routes
    ADD FOREIGN KEY (station_id) REFERENCES stations