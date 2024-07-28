-- создадим enum тип
CREATE TYPE ENGINE_TYPE AS ENUM
    ('бензиновый', 'дизельный', 'электрический', 'гибридный');

CREATE TABLE cars (
    PRIMARY KEY (guid),
    guid    UUID DEFAULT gen_random_uuid(),
    gos_num CHAR(9),
    engine  ENGINE_TYPE
);

INSERT INTO cars (gos_num, engine)
VALUES ('A111AA111', 'электрический'),
       ('B222BB222', 'бензиновый');

-- создадим еще ENUM для массива
CREATE TYPE LICENSE_CATEGORY AS ENUM ('M', 'A', 'A1', 'B', 'BE', 'B1', 'C', 'CE', 'C1',
    'C1E', 'D', 'DE', 'D1', 'D1E', 'F', 'Tm', 'Tb');

ALTER TABLE drivers
    ADD COLUMN category LICENSE_CATEGORY[];

UPDATE drivers SET category = '{A, B, C}'
WHERE name = 'Колесов Игорь Витальевич';