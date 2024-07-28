-- создаем ссоставной тип
CREATE TYPE CAR_SPECIFICATIONS AS (
    vin              CHAR(17),
    manufacture_year SMALLINT,
    color            TEXT,
    engine_volume    NUMERIC,
    engine_power     NUMERIC
);

ALTER TABLE cars
    ADD COLUMN specifications CAR_SPECIFICATIONS;

-- вставляем данные
UPDATE cars
   SET specifications = '(AAA12345678901234,2015,белый,1.3,136)'
 WHERE gos_num = 'A111AA111';

-- с пропуском значений
UPDATE cars
   SET specifications = '(BBB12345678901234,2020,жёлтый,,150)'
 WHERE gos_num = 'B222BB222';

-- используем ROW
INSERT INTO cars (gos_num, engine, specifications)
VALUES ('E444EE444', 'гибридный', ROW ('MMM12345678901234', 2021, 'чёрный', NULL, NULL));

-- можно и без ROW
INSERT INTO cars (gos_num, engine, specifications)
VALUES ('E444EE444', 'гибридный', ('MMM12345678901234', 2021, 'чёрный', NULL, NULL));

-- выборка данных
SELECT specifications
  FROM cars;

SELECT (cars).guid
  FROM cars;

SELECT (specifications).manufacture_year
  FROM cars;

-- изменяем и вставляем значения
UPDATE cars
   SET specifications.color = 'синий'
 WHERE gos_num = 'A111AA111';

-- добавить 3-й магазин
INSERT INTO shops (address, properties, services)
VALUES ('пер. Огуречный, 7', (70, 1, '12:34:567890:12', TRUE), '{самовывоз, свежевыжатые соки}');

-- найти площадь склада
SELECT (properties).area
  FROM storehouses
 WHERE id = 2;

-- исправить значение
UPDATE shops
   SET properties.is_owned = TRUE
 WHERE id = 2;

-- указать кадастровый номер
UPDATE storehouses
   SET properties.cadastral_num = '00:77:567890:12'
 WHERE id = 3;