-- установка и удаление расширения
CREATE EXTENSION IF NOT EXISTS postgis;
DROP EXTENSION IF EXISTS postgis;

-- проверка версии
SELECT postgis_full_version();

-- создать точку
SELECT st_geomfromtext('LINESTRING(-5 0, -4 4, -2 -4, 1 2, 12 0, -5 0)');

SELECT st_geomfromtext('LINESTRING(-3 5, 2 5, -3 1, 2 1, -3 -4 )');

SELECT '0101000000000000000000F03F000000000000F03F'::GEOMETRY;

SELECT st_geomfromwkb('\x0101000000000000000000f03f000000000000f03f');

SELECT st_geomfromwkb(
               E'\\001\\002\\000\\000\\000\\002\\000\\000\\000\\037\\205\\353Q\\270'
                   '~\\\\\\300\\323Mb\\020X\\231C@\\020X9\\264\\310~\\\\\\300)\\\\\\'
                   '217\\302\\365\\230C@'
       );

SELECT '010500000003000000010200000002000000000000000000'
           '14C0000000000000104000000000000014C0000000000000'
           '10C001020000000200000000000000000014C00000000000'
           '00000000000000000000C000000000000000000102000000'
           '0500000000000000000000C0000000000000104000000000'
           '000000400000000000001040000000000000004000000000'
           '000010C000000000000000C000000000000010C000000000'
           '000000C00000000000001040'::GEOMETRY;

-- полигоны
SELECT st_geomfromtext('POLYGON(
    (0 0, 0 10, 6 10, 6 0, 0 0),
    (0.5 0.5, 0.5 5, 5.5 5, 5.5 0.5, 0.5 0.5),
    (0.5 5.5, 0.5 9.5, 5.5 9.5, 5.5 5.5, 0.5 5.5)
)');

SELECT st_geomfromtext('MULTILINESTRING((-4 4, -4 -4, 4 4, 4 -4), (-1 5, 1 5))');

-- создадим таблицу с геоданными
CREATE TABLE places (
    PRIMARY KEY (place_id),
    place_id SERIAL,
    name     TEXT,
    gm       GEOMETRY,
    gg       GEOGRAPHY
);

INSERT INTO places (name, gg, gm)
VALUES ('Moscow Kremlin',
        'POINT(37.617330 55.750997)',
        'POINT(37.617330 55.750997)');

SELECT *
  FROM places;

SELECT place_id,
       name,
       st_astext(gm) AS geometry_text,
       st_astext(gg) AS geography_text
  FROM places;

INSERT INTO places (name, gm, gg)
VALUES ('', 'LINESTRING(-73.99945 40.708231, -73.9937 40.703676)', 'LINESTRING(-73.99945 40.708231, -73.9937 40.703676)');

INSERT INTO places(name, gm, gg)
VALUES ('', 'POLYGON((37.6180 55.7545, 37.6215 55.7526, 37.6225 55.7535, 37.6190 55.7552, 37.6180 55.7545))',
        'POLYGON((37.6180 55.7545, 37.6215 55.7526, 37.6225 55.7535, 37.6190 55.7552, 37.6180 55.7545))');

-- создать таблицу для хранения координат
CREATE TABLE localities (
    PRIMARY KEY (id),
    id       SERIAL,
    locality TEXT,
    position GEOGRAPHY(POINT)
);

INSERT INTO localities (locality, position)
VALUES ('Белая Холуница', 'POINT(50.846416 58.841688)'),
       ('Великое Поле', 'POINT(50.877155 58.854204)'),
       ('Иванцево', 'POINT(51.002238 59.129581)');

-- создать таблицу для аномальных мест
CREATE TABLE anomalies (
    PRIMARY KEY (id),
    id      SERIAL,
    anomaly TEXT,
    shape   GEOGRAPHY(POLYGON)
);

INSERT INTO anomalies (anomaly, shape)
VALUES ('Bermuda Triangle', 'POLYGON((-80.1 25.7, -67.4 18.5, -64.8 32.3, -80.1 25.7))'),
       ('Loch Ness', 'POLYGON((-4.6752 57.1484, -4.6696 57.1392, -4.4954 57.2586, -4.3330 57.3821, -4.3660 57.3873, -4.5166 57.2626, -4.6752 57.1484))');

-- создать таблицу Соловки
CREATE TABLE solovki (
    islands GEOGRAPHY(MULTIPOLYGON)
);

   INSERT INTO solovki (islands)
   VALUES ('MULTIPOLYGON(
    ((35.679 65.035, 35.741 64.952, 35.884 64.985,
35.845 65.134, 35.743 65.178, 35.508 65.145, 35.499 65.091,
35.596 65.036, 35.679 65.035)),
    ((35.994 65.192, 35.932 65.182, 35.927 65.142,
36.072 65.122, 36.276 65.153, 36.270 65.165, 36.063 65.156,
35.994 65.192)),
    ((35.880 65.042, 35.875 65.034, 35.895 65.026,
35.879 65.021, 35.907 65.014, 35.949 65.023, 36.010 65.018,
36.025 65.033, 36.020 65.045, 35.977 65.056, 35.880 65.042)))')
RETURNING st_astext(islands);

-- зададим SRID вручную
CREATE TABLE geometry_4326 (
    PRIMARY KEY (id),
    id    SERIAL,
    place TEXT,
    gm    GEOMETRY(POINT, 4326)
);

INSERT INTO geometry_4326 (place, gm)
VALUES ('Moscow Kremlin',
        'POINT(37.617330 55.750997)' -- WKT передается без указания SRID.
       );

-- узнать SRID
SELECT st_srid(gm)
  FROM geometry_4326;

-- указываем SRID
SELECT st_setsrid(gm, 3857)
  FROM geometry_4326;

-- трансформация SRID
SELECT st_astext(st_transform(gm, 3857))
  FROM geometry_4326;

-- используем EWKT
INSERT INTO geometry_4326 (place, gm)
VALUES (
           -- чтобы вставить обычный апостроф, указываем его дважды
           'Saint Petersburg''s Winter Palace',
           'SRID=4326;POINT(30.313062 59.940937)' -- геометрия в формате EWKT
       );

-- в GeoJSON (обратно ST_GeomFromGeoJSON)
SELECT st_asgeojson(gm)
  FROM places;

-- тест
SELECT st_geomfromgeojson('
    {"type": "Point",
     "coordinates": [39.88223925980441,59.22361416209884]}
');

-- создать таблицу Кремлинс
CREATE TABLE kremlins (
    PRIMARY KEY (id),
    id    SERIAL,
    name  TEXT                  NOT NULL
        UNIQUE,
    point GEOMETRY(POINT, 4326) NOT NULL
);

-- вставить данные
INSERT INTO kremlins (name, point)
VALUES ('Kazan Kremlin', 'POINT(49.106086 55.799176)');

-- вставить данные другого SRID
INSERT INTO kremlins (name, point)
VALUES ('Zaraysk Kremlin', st_setsrid(st_transform('SRID=3857;POINT(4327175.14880196 7314886.348288048)', 4326), 4326));

-- вернуть данные в JSON
   INSERT INTO kremlins (name, point)
   VALUES ('Nizhny Novgorod Kremlin', 'POINT(44.003760539 56.328624716)')
RETURNING st_asgeojson(point);

-- проверяем тождественность
SELECT st_equals(
               st_geomfromtext('POINT(1 1)'),
               st_geomfromtext('POINT(1 1)')
       );

-- ST_Within(A, B) - строго входит, и не персекается на границе
-- ST_Contains(А, В) - входит, но может быть пересечение на границу, но не полные
-- ST_Covers(A, B) - входит, и весь может находится на границе
-- ST_Intersects - пересечение есть или нет
-- ST_Intersection - вернет объекты, которые пересекаются

-- узнаем расстояние в градусах
SELECT st_distance(
               'POINT(30.316 59.939)',
               'POINT(37.6205 55.7541)'
       );

-- узнаем расстояние в метрах (без учета кривизны)
SELECT st_distance(
               st_transform(st_geomfromtext('POINT(30.316 59.939)', 4326), 3857),
               st_transform(st_geomfromtext('POINT(37.6205 55.7541)', 4326), 3857)
       );

-- с учетом кривизны
SELECT st_distance(
               'POINT(30.316 59.939)'::GEOGRAPHY,
               'POINT(37.6205 55.7541)'::GEOGRAPHY
       );

-- длина по линиям
SELECT st_length(
               st_geomfromgeojson('{
        "coordinates": [
          [38.1334, 56.3136],
          [38.8484, 56.7367],
          [39.4232, 57.1875],
          [39.8974, 57.6320],
          [40.9379, 57.7678],
          [40.9769, 56.9972],
          [40.4519, 56.4190],
          [40.4087, 56.1287]],
        "type": "LineString"
      }')::GEOGRAPHY
       );

-- посчитаем перемитр
SELECT st_perimeter(
               st_geomfromgeojson('{
        "coordinates": [[
          [38.1334, 56.3136],
          [38.8484, 56.7367],
          [39.4232, 57.1875],
          [39.8974, 57.6320],
          [40.9379, 57.7678],
          [40.9769, 56.9972],
          [40.4519, 56.4190],
          [40.4087, 56.1287],
          [38.1334, 56.3136]
          ]],
        "type": "Polygon"
      }')::GEOGRAPHY
       );

-- ST_Area для расчета площади

-- все кремли Москвы
SELECT kremlins.name
  FROM kremlins
           INNER JOIN cities ON st_within(kremlins.shape, cities.shape::GEOMETRY)
 WHERE cities.name = 'Москва';

-- все кремли без городов
SELECT kremlins.name
  FROM kremlins
           LEFT JOIN cities ON st_within(kremlins.shape, cities.shape::GEOMETRY)
 WHERE cities.name IS NULL;

-- вывести все площади кремлей
SELECT name, ROUND(st_area(shape::GEOGRAPHY)) AS area
  FROM kremlins
 ORDER BY area DESC;

-- относительную площадь
SELECT kremlins.name,
       st_area(kremlins.shape::GEOGRAPHY) / st_area(cities.shape) * 100 AS ratio
  FROM kremlins
           INNER JOIN cities ON st_within(kremlins.shape, cities.shape::GEOMETRY)
 ORDER BY ratio DESC;

-- максимально далекие кремли
SELECT kremlins_1.name                                                              AS kremlin_1,
       kremlins_2.name                                                              AS kremlin_2,
       ROUND(st_distance(kremlins_1.shape::GEOGRAPHY, kremlins_2.shape::GEOGRAPHY)) AS distance
  FROM kremlins AS kremlins_1
           CROSS JOIN kremlins AS kremlins_2
 ORDER BY distance DESC
 LIMIT 1;
