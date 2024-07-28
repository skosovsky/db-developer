-- генерация uuid
SELECT gen_random_uuid();

-- пример создания таблицы
CREATE TABLE drivers (
    PRIMARY KEY (driver_guid),
    driver_guid UUID DEFAULT gen_random_uuid(),
    name        TEXT,
    license     BIGINT,
    depot_id    INTEGER
);

INSERT INTO drivers (name, license, depot_id)
VALUES ('Иванов Сергей Олегович', 7777123123, 1);