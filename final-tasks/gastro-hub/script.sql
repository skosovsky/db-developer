-- create database
CREATE DATABASE gastro_hub;

-- add extensions
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto; -- for UUID v7

-- restore from dump
-- /Library/PostgreSQL/16/bin/pg_restore --dbname=gastro_hub --username=postgres --host=localhost --port=5432 "/Users/skosovsky/sprint2_dump.sql"

-- create func for generate UUID v7 - https://github.com/Betterment/postgresql-uuid-generate-v7/blob/main/uuid_generate_v7.sql
CREATE OR REPLACE FUNCTION
    uuid_generate_v7()
    RETURNS
        UUID
    LANGUAGE plpgsql
    PARALLEL SAFE
AS
$$
DECLARE
    unix_time_ms CONSTANT BYTEA NOT NULL DEFAULT SUBSTRING(int8send((EXTRACT(EPOCH FROM CLOCK_TIMESTAMP()) * 1000)::BIGINT) FROM 3);
    buffer                BYTEA NOT NULL DEFAULT unix_time_ms || gen_random_bytes(10);
BEGIN
    buffer = SET_BYTE(buffer, 6, (b'0111' || GET_BYTE(buffer, 6)::BIT(4))::BIT(8)::INT);
    buffer = SET_BYTE(buffer, 8, (b'10' || GET_BYTE(buffer, 8)::BIT(6))::BIT(8)::INT);
    RETURN ENCODE(buffer, 'hex');
END
$$;

-- create enum
CREATE TYPE cafe.RESTAURANT_TYPE AS ENUM
    ('coffee_shop', 'restaurant', 'bar', 'pizzeria');

-- create tables
CREATE TABLE IF NOT EXISTS cafe.restaurants (
    PRIMARY KEY (restaurant_uuid),
    restaurant_uuid UUID DEFAULT uuid_generate_v7(),
    name            VARCHAR(50),
    location        GEOMETRY(POINT, 4326),
    type            cafe.RESTAURANT_TYPE,
    menu            JSONB
);

CREATE TABLE IF NOT EXISTS cafe.managers (
    PRIMARY KEY (manager_uuid),
    manager_uuid UUID DEFAULT uuid_generate_v7(),
    name         VARCHAR(128),
    phone        VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS cafe.restaurant_manager_work_dates (
    PRIMARY KEY (restaurant_uuid, manager_uuid),
    restaurant_uuid UUID,
    manager_uuid    UUID,
    started_dt      DATE,
    finished_dt     DATE
);

CREATE TABLE IF NOT EXISTS cafe.sales (
    PRIMARY KEY (date, restaurant_uuid),
    date            DATE,
    restaurant_uuid UUID,
    avg_check       NUMERIC(6, 2)
);

-- insert data
INSERT INTO cafe.restaurants(name, location, type, menu)
SELECT DISTINCT cafe_name                                       AS name,
                st_setsrid(st_point(longitude, latitude), 4326) AS location,
                type::cafe.RESTAURANT_TYPE                      AS type,
                menu                                            AS menu
  FROM raw_data.sales
           INNER JOIN raw_data.menu USING (cafe_name);

INSERT INTO cafe.managers (name, phone)
SELECT DISTINCT manager       AS name,
                manager_phone AS phone
  FROM raw_data.sales;

INSERT INTO cafe.restaurant_manager_work_dates (restaurant_uuid, manager_uuid, started_dt, finished_dt)
SELECT restaurant_uuid,
       manager_uuid,
       MIN(report_date) AS started_dt,
       MAX(report_date) AS finished_dt
  FROM cafe.restaurants
           INNER JOIN raw_data.sales ON raw_data.sales.cafe_name = cafe.restaurants.name
           INNER JOIN cafe.managers ON raw_data.sales.manager = cafe.managers.name
 GROUP BY restaurant_uuid, manager_uuid;

INSERT INTO cafe.sales
SELECT report_date AS date,
       restaurant_uuid,
       avg_check
  FROM raw_data.sales
           INNER JOIN cafe.restaurants ON cafe.restaurants.name = raw_data.sales.cafe_name;

-- task 1: create view with top restaurants by type
CREATE VIEW cafe.top_restaurants_by_type AS
  WITH top_restaraunts AS (SELECT name                                  AS restaraunt_name,
                                  type                                  AS restaraunt_type,
                                  ROUND(AVG(avg_check), 2)              AS average_check,
                                  ROW_NUMBER() OVER (PARTITION BY type) AS restaraunt_rank
                             FROM cafe.restaurants
                                      INNER JOIN cafe.sales USING (restaurant_uuid)
                            GROUP BY name, type
                            ORDER BY restaraunt_type, average_check DESC, restaraunt_name)

SELECT restaraunt_name, restaraunt_type, average_check
  FROM top_restaraunts
 WHERE restaraunt_rank <= 3;

-- task 2: create materialized view like for like
CREATE MATERIALIZED VIEW cafe.like_for_like AS
  WITH avg_check_by_year AS (SELECT EXTRACT(YEAR FROM date)  AS year,
                                    restaurants.name         AS restaurant_name,
                                    restaurants.type         AS restaurant_type,
                                    ROUND(AVG(avg_check), 2) AS avg_check_current_year
                               FROM cafe.sales
                                        INNER JOIN cafe.restaurants USING (restaurant_uuid)
                              WHERE cafe.sales.date < '2023-01-01'
                              GROUP BY year, restaurants.name, restaurants.type)

SELECT *,
       ROUND(LAG(avg_check_current_year) OVER (PARTITION BY year), 2)                              AS avg_check_previous_year,
       ROUND(avg_check_current_year / LAG(avg_check_current_year) OVER (PARTITION BY year) - 1, 2) AS lfl
  FROM avg_check_by_year
 GROUP BY year, restaurant_name, restaurant_type, avg_check_current_year
 ORDER BY restaurant_name, year;

-- task 3: table with often changed managers
SELECT restaurants.name             AS restaurant_name,
       COUNT(DISTINCT manager_uuid) AS count_managers
  FROM cafe.restaurants
           INNER JOIN cafe.restaurant_manager_work_dates USING (restaurant_uuid)
 GROUP BY restaurants.name
 ORDER BY count_managers DESC, restaurant_name
 LIMIT 3;

-- task 4: table with max pizzas
SELECT restaurant_name, count_pizza
  FROM (SELECT restaurant_name,
               COUNT(pizza_name)                                   AS count_pizza,
               DENSE_RANK() OVER (ORDER BY COUNT(pizza_name) DESC) AS pizza_rank
          FROM (SELECT restaurants.name                 AS restaurant_name,
                       JSONB_EACH_TEXT(menu -> 'Пицца') AS pizza_name
                  FROM cafe.restaurants) AS restaraunts_pizzas
         GROUP BY restaurant_name) AS restaraunts_pizzas_rank
 WHERE pizza_rank = 1;

-- task 5: table with expensive pizza
SELECT restaurant_name, dish_type, pizza_name, pizza_price
  FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY restaurant_name ORDER BY pizza_price DESC) AS pizza_rank
          FROM (SELECT restaurants.name                              AS restaurant_name,
                       'Пицца'                                       AS dish_type,
                       (JSONB_EACH_TEXT(menu -> 'Пицца')).key        AS pizza_name,
                       (JSONB_EACH_TEXT(menu -> 'Пицца')).value::INT AS pizza_price
                  FROM cafe.restaurants
                 ORDER BY restaurant_name, pizza_price, pizza_name) AS menu_with_pizza) AS pizza_with_rank
 WHERE pizza_rank = 1
 ORDER BY pizza_price DESC;

-- task 6: two nearest restaurants
SELECT restaurant_1,
       restaurant_2,
       type,
       st_distance(location_1::GEOGRAPHY, location_2::GEOGRAPHY) AS distance
  FROM (SELECT DISTINCT restaurants_1.name     AS restaurant_1,
                        restaurants_2.name     AS restaurant_2,
                        restaurants_1.type     AS type,
                        restaurants_1.location AS location_1,
                        restaurants_2.location AS location_2
          FROM cafe.restaurants                AS restaurants_1
                   CROSS JOIN cafe.restaurants AS restaurants_2
         WHERE restaurants_1.type = restaurants_2.type
           AND restaurants_1.name <> restaurants_2.name) AS cross_restaurants
 ORDER BY distance
 LIMIT 1;

-- task 7: find area where min or max restaurant
  WITH distrits_min_max AS (SELECT MIN(district_count) AS min_count,
                                   MAX(district_count) AS max_count
                              FROM (SELECT district_name,
                                           COUNT(district_name) AS district_count
                                      FROM (SELECT name,
                                                   district_name
                                              FROM cafe.restaurants
                                                       CROSS JOIN cafe.districts
                                             WHERE st_within(location, district_geom) = TRUE) AS restaurants_districts
                                     GROUP BY district_name) AS distrits_counts),
       districts_counts AS (SELECT district_name,
                                   COUNT(district_name) AS district_count
                              FROM (SELECT name,
                                           district_name
                                      FROM cafe.restaurants
                                               CROSS JOIN cafe.districts
                                     WHERE st_within(location, district_geom) = TRUE) AS restaurants_districts
                             GROUP BY district_name)

SELECT district_name, district_count
  FROM districts_counts
 WHERE district_count = (SELECT max_count FROM distrits_min_max)
    OR district_count = (SELECT min_count FROM distrits_min_max);