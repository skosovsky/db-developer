CREATE TABLE trains (
    PRIMARY KEY (id),
    id                   SERIAL,
    number               VARCHAR(13),
    departure_station_id INTEGER
        REFERENCES stations,
    departure_date       TIMESTAMP,
    arrival_station_id   INTEGER
        REFERENCES stations,
    arrival_date         TIMESTAMP
);

CREATE TABLE car_types (
    PRIMARY KEY (id),
    id   SERIAL,
    name TEXT
);

CREATE TABLE cars (
    PRIMARY KEY (id),
    id      SERIAL,
    type_id INTEGER
        REFERENCES car_types DEFAULT 1,
    number  VARCHAR(6)
);

CREATE TABLE cars_in_trains (
    PRIMARY KEY (id),
    id          SERIAL,
    train_id    INTEGER
        REFERENCES trains,
    car_id      INTEGER
        REFERENCES cars,
    attach_date TIMESTAMP,
    detach_date TIMESTAMP,
    shipment_id INTEGER
        REFERENCES shipments
);

CREATE TABLE cars_have_no_passports (
    PRIMARY KEY (id),
    id         SERIAL,
    car_id     INTEGER
        UNIQUE
        REFERENCES cars,
    date_entry TIMESTAMP
);

INSERT INTO car_types (id, name)
VALUES (1, 'вагон'),
       (2, 'логомотив'),
       (3, 'полувагон'),
       (4, 'рефрежиратор'),
       (5, 'технический');

INSERT INTO cars (number, type_id)
VALUES (123456, 1),
       (234567, 1),
       (345678, 1),
       (456789, 2),
       (567890, 2);

INSERT INTO cars_have_no_passports (car_id, date_entry)
VALUES (5, NULL);

INSERT INTO trains (number, departure_station_id, departure_date, arrival_station_id, arrival_date)
VALUES ('1234 567 8901', 1, TO_TIMESTAMP('20.06.2023 10:00:00', 'dd.mm.yyyy hh24:mi:ss'), 4, NULL);

INSERT INTO cars_in_trains (train_id, car_id, attach_date, detach_date, shipment_id)
VALUES (1, 4, TO_TIMESTAMP('20.06.2023 10:00:00', 'dd.mm.yyyy hh24:mi:ss'), NULL, NULL),
       (1, 1, TO_TIMESTAMP('20.06.2023 10:00:00', 'dd.mm.yyyy hh24:mi:ss'),
        TO_TIMESTAMP('25.06.2023 10:00:00', 'dd.mm.yyyy hh24:mi:ss'), 1);

INSERT INTO trains (number, departure_station_id, departure_date, arrival_station_id, arrival_date)
VALUES ('2345 678 9012', 2, TO_TIMESTAMP('22.06.2023 10:00:00', 'dd.mm.yyyy hh24:mi:ss'), 5,
        TO_TIMESTAMP('30.06.2023 10:00:00', 'dd.mm.yyyy hh24:mi:ss'));

INSERT INTO cars_in_trains (train_id, car_id, attach_date, detach_date, shipment_id)
VALUES (2, 5, TO_TIMESTAMP('22.06.2023 10:00:00', 'dd.mm.yyyy hh24:mi:ss'),
        TO_TIMESTAMP('30.06.2023 10:00:00', 'dd.mm.yyyy hh24:mi:ss'), NULL),
       (2, 2, TO_TIMESTAMP('22.06.2023 10:00:00', 'dd.mm.yyyy hh24:mi:ss'),
        TO_TIMESTAMP('30.06.2023 10:00:00', 'dd.mm.yyyy hh24:mi:ss'), 2),
       (2, 3, TO_TIMESTAMP('25.06.2023 10:00:00', 'dd.mm.yyyy hh24:mi:ss'),
        TO_TIMESTAMP('30.06.2023 10:00:00', 'dd.mm.yyyy hh24:mi:ss'), 3);

ALTER TABLE shipments
    ADD COLUMN cars_in_trains_id INTEGER
        REFERENCES cars_in_trains;

UPDATE shipments
   SET cars_in_trains_id = 2
 WHERE id = 1;

UPDATE shipments
   SET cars_in_trains_id = 4
 WHERE id = 2;

UPDATE shipments
   SET cars_in_trains_id = 5
 WHERE id = 3;

-- проверка
SELECT name
  FROM car_types ct
           JOIN cars c ON c.type_id = ct.id
           JOIN cars_in_trains ctr ON ctr.car_id = c.id
           JOIN trains t ON t.id = ctr.train_id
 WHERE t.number = '1234 567 8901'
   AND ctr.detach_date IS NULL;

SELECT COUNT(*)
  FROM shipments
 WHERE cars_in_trains_id IS NULL;