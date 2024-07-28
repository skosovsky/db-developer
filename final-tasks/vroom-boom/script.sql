-- create schema 'raw_data'
CREATE SCHEMA IF NOT EXISTS raw_data;

-- create table 'sales' for raw fata
CREATE TABLE IF NOT EXISTS raw_data.sales (
    PRIMARY KEY (id),
    id                   INTEGER,
    auto                 VARCHAR,
    gasoline_consumption REAL,
    price                REAL,
    date                 DATE,
    person_name          VARCHAR,
    phone                VARCHAR,
    discount             INTEGER,
    brand_origin         VARCHAR
);

-- import raw data to table
COPY raw_data.sales FROM '/Users/skosovsky/cars.csv' WITH CSV HEADER NULL 'null';

-- create schema 'car_shop'
CREATE SCHEMA IF NOT EXISTS car_shop;

-- create table 'persons'
CREATE TABLE IF NOT EXISTS car_shop.persons (
    PRIMARY KEY (person_id),
    person_id  SERIAL,           -- key
    appeal     VARCHAR(32) NULL, -- short appeal
    first_name VARCHAR(64),      -- middle first name
    last_name  VARCHAR(128),     -- long last name
    degrees    VARCHAR(16),      -- very short degree
    full_name  VARCHAR(256),     -- temporarily
    full_phone VARCHAR(128)      -- temporarily
);

-- insert data to 'persons'
INSERT INTO car_shop.persons(full_name, full_phone)
SELECT DISTINCT person_name, phone
  FROM raw_data.sales;

-- update data from 'person', move 'appeal'
UPDATE car_shop.persons
   SET appeal    = CASE
                       WHEN SUBSTR(full_name, 1, 4) = 'Miss' THEN 'Miss'
                       WHEN SUBSTR(full_name, 1, 4) = 'Mrs.' THEN 'Mrs.'
                       WHEN SUBSTR(full_name, 1, 3) = 'Mr.'  THEN 'Mr.'
                       WHEN SUBSTR(full_name, 1, 3) = 'Dr.'  THEN 'Dr.'
                                                             ELSE NULL
                   END,
       full_name = CASE
                       WHEN SUBSTR(full_name, 1, 4) = 'Miss' THEN SUBSTR(full_name, 6)
                       WHEN SUBSTR(full_name, 1, 4) = 'Mrs.' THEN SUBSTR(full_name, 6)
                       WHEN SUBSTR(full_name, 1, 3) = 'Mr.'  THEN SUBSTR(full_name, 5)
                       WHEN SUBSTR(full_name, 1, 3) = 'Dr.'  THEN SUBSTR(full_name, 5)
                                                             ELSE full_name
                   END
 WHERE full_name IS NOT NULL;

-- update data from 'person', move 'degrees'
UPDATE car_shop.persons
   SET degrees   = CASE
                       WHEN SPLIT_PART(full_name, ' ', -1) = 'DVM' THEN SPLIT_PART(full_name, ' ', -1)
                       WHEN SPLIT_PART(full_name, ' ', -1) = 'DDS' THEN SPLIT_PART(full_name, ' ', -1)
                       WHEN SPLIT_PART(full_name, ' ', -1) = 'MD'  THEN SPLIT_PART(full_name, ' ', -1)
                                                                   ELSE NULL
                   END,
       full_name = TRIM(RTRIM(full_name, 'MDVS'))
 WHERE full_name IS NOT NULL;

-- update data from 'person', move 'first_name' and 'last_name'
UPDATE car_shop.persons
   SET first_name = SPLIT_PART(full_name, ' ', 1),
       last_name  = SUBSTR(full_name, STRPOS(full_name, ' ') + 1)
 WHERE full_name IS NOT NULL;

-- drop temporary 'full_name'
ALTER TABLE car_shop.persons
    DROP COLUMN full_name;

-- add constrains to 'first_name'
ALTER TABLE car_shop.persons
    ALTER COLUMN first_name SET NOT NULL;

-- create table 'phones'
CREATE TABLE IF NOT EXISTS car_shop.phones (
    PRIMARY KEY (phone_id),
    phone_id     SERIAL,      -- key
    person_id    INTEGER      -- link with person
        REFERENCES car_shop.persons (person_id),
    country_code VARCHAR(8),  -- very short country code
    code         VARCHAR(8),  -- very short phone code
    number       VARCHAR(64), -- short phone number
    extension    VARCHAR(8),  -- very short phone extension
    full_phone   VARCHAR(128) -- temporarily
);

-- insert data to 'phones'
INSERT INTO car_shop.phones(person_id, full_phone)
SELECT person_id, full_phone
  FROM car_shop.persons;

-- drop temporary 'full_phone'
ALTER TABLE car_shop.persons
    DROP COLUMN full_phone;

-- prepare data for uniform format
UPDATE car_shop.phones
   SET full_phone = REPLACE(REPLACE(full_phone, '-', ''), '.', '')
 WHERE full_phone IS NOT NULL;

-- update data from 'phones', move 'phone_extension'
UPDATE car_shop.phones
   SET extension  = CASE
                        WHEN STRPOS(full_phone, 'x') <> 0 THEN SUBSTR(full_phone, STRPOS(full_phone, 'x') + 1)
                                                          ELSE NULL
                    END,
       full_phone = CASE
                        WHEN STRPOS(full_phone, 'x') <> 0 THEN SUBSTR(full_phone, 1, STRPOS(full_phone, 'x') - 1)
                                                          ELSE full_phone
                    END
 WHERE full_phone IS NOT NULL;

-- update data from 'phones', move 'country_code'
UPDATE car_shop.phones
   SET country_code = CASE
                          WHEN SUBSTR(full_phone, 1, 2) = '+1'  THEN '+1'
                          WHEN SUBSTR(full_phone, 1, 3) = '001' THEN '+1'
                                                                ELSE NULL
                      END,
       full_phone   = CASE
                          WHEN SUBSTR(full_phone, 1, 2) = '+1'  THEN SUBSTR(full_phone, 3)
                          WHEN SUBSTR(full_phone, 1, 3) = '001' THEN SUBSTR(full_phone, 4)
                                                                ELSE full_phone
                      END
 WHERE full_phone IS NOT NULL;

-- update data from 'phones', move 'phone_code'
UPDATE car_shop.phones
   SET code       = CASE
                        WHEN SUBSTR(full_phone, 5, 1) = ')' THEN SUBSTR(full_phone, 2, 3)
                                                            ELSE NULL
                    END,
       full_phone = CASE
                        WHEN SUBSTR(full_phone, 5, 1) = ')' THEN SUBSTR(full_phone, 6)
                                                            ELSE full_phone
                    END
 WHERE full_phone IS NOT NULL;

-- update data from 'phones', move 'phone_number'
UPDATE car_shop.phones
   SET number = full_phone
 WHERE full_phone IS NOT NULL;

-- drop temporary 'full_phone'
ALTER TABLE car_shop.phones
    DROP COLUMN full_phone;

-- create table 'colors'
CREATE TABLE IF NOT EXISTS car_shop.colors (
    PRIMARY KEY (color_id),
    color_id SERIAL,     -- key
    name     VARCHAR(64) -- middle color name
);

-- insert data to 'colors'
INSERT INTO car_shop.colors (name)
SELECT DISTINCT SPLIT_PART(auto, ', ', -1) AS color
  FROM raw_data.sales
 ORDER BY color;

-- create table 'countries'
CREATE TABLE IF NOT EXISTS car_shop.countries (
    PRIMARY KEY (country_id),
    country_id SERIAL,          -- key
    name       VARCHAR(60) NULL -- max symbol name (The United Kingdom of Great Britain and Northern Ireland)
);

-- insert date to 'countries'
INSERT INTO car_shop.countries(name)
SELECT DISTINCT brand_origin
  FROM raw_data.sales
 ORDER BY brand_origin;

-- create table 'brands'
CREATE TABLE IF NOT EXISTS car_shop.brands (
    PRIMARY KEY (brand_id),
    brand_id   SERIAL,      -- key
    name       VARCHAR(64), -- middle brand name
    country_id INTEGER      -- foreign key
        REFERENCES car_shop.countries
);

-- insert data to 'brands'
INSERT INTO car_shop.brands (name, country_id)
SELECT DISTINCT SPLIT_PART(auto, ' ', 1) AS brand, car_shop.countries.country_id
  FROM raw_data.sales
           INNER JOIN car_shop.countries ON raw_data.sales.brand_origin = car_shop.countries.name
 ORDER BY brand;

-- create table 'models'
CREATE TABLE IF NOT EXISTS car_shop.models (
    PRIMARY KEY (model_id),
    model_id             SERIAL,      -- key
    name                 VARCHAR(64), -- middle model name
    brand_id             INTEGER      -- foreign key
        REFERENCES car_shop.brands,
    gasoline_consumption REAL         -- not need precision
);

-- insert data to 'models'
INSERT INTO car_shop.models (name, brand_id, gasoline_consumption)
SELECT DISTINCT SUBSTR(auto,
                       STRPOS(auto, ' ') + 1,
                       LENGTH(auto) - STRPOS(auto, ' ') - LENGTH(SUBSTR(auto, STRPOS(auto, ',')))) AS model,
                car_shop.brands.brand_id,
                raw_data.sales.gasoline_consumption
  FROM raw_data.sales
           INNER JOIN car_shop.brands ON SPLIT_PART(raw_data.sales.auto, ' ', 1) = car_shop.brands.name
 ORDER BY model;

-- create table 'cars'
CREATE TABLE IF NOT EXISTS car_shop.cars (
    PRIMARY KEY (car_id),
    car_id   SERIAL,                -- key
    model_id INTEGER
        REFERENCES car_shop.models, -- foreign key
    color_id INTEGER
        REFERENCES car_shop.colors  -- foreign key
);

-- insert data to 'cars'
INSERT INTO car_shop.cars (model_id, color_id)
SELECT DISTINCT models.model_id, colors.color_id
  FROM car_shop.models
           INNER JOIN car_shop.brands ON car_shop.models.brand_id = car_shop.brands.brand_id
           INNER JOIN raw_data.sales ON (SPLIT_PART(raw_data.sales.auto, ' ', 1) = car_shop.brands.name) -- check brand, may be model is same
      AND (SUBSTR(raw_data.sales.auto,
                  STRPOS(raw_data.sales.auto, ' ') + 1,
                  LENGTH(raw_data.sales.auto) - STRPOS(raw_data.sales.auto, ' ') - LENGTH(SUBSTR(raw_data.sales.auto, STRPOS(raw_data.sales.auto, ',')))) = models.name)
           INNER JOIN car_shop.colors ON SPLIT_PART(raw_data.sales.auto, ', ', -1) = colors.name;

-- create table 'sales'
CREATE TABLE IF NOT EXISTS car_shop.sales (
    PRIMARY KEY (sale_id),
    sale_id   SERIAL,       -- key
    car_id    INTEGER       -- foreign key
        REFERENCES car_shop.cars,
    person_id INTEGER       -- foreign key
        REFERENCES car_shop.persons,
    sale_date DATE,         -- date
    price     NUMERIC(9, 2) -- money
);

-- insert data to 'sales'
INSERT INTO car_shop.sales(car_id, person_id, sale_date, price)
SELECT cars.car_id, persons.person_id, raw_data.sales.date, raw_data.sales.price::NUMERIC(9, 2)
  FROM car_shop.cars
           INNER JOIN car_shop.models USING (model_id)
           INNER JOIN car_shop.brands USING (brand_id)
           INNER JOIN car_shop.colors USING (color_id)
           INNER JOIN raw_data.sales ON auto = CONCAT(car_shop.brands.name, ' ', car_shop.models.name, ', ', car_shop.colors.name)
           INNER JOIN car_shop.persons
                      ON raw_data.sales.person_name = CONCAT_WS(' ', car_shop.persons.appeal, car_shop.persons.first_name, car_shop.persons.last_name, car_shop.persons.degrees)
 ORDER BY car_id;

-- create table 'discounts'
CREATE TABLE IF NOT EXISTS car_shop.discounts (
    PRIMARY KEY (discount_id),
    discount_id SERIAL,       -- key
    sale_id     INTEGER       -- foreign key
        REFERENCES car_shop.sales,
    discount    NUMERIC(2, 2) -- percent, format 0.5 = 50%
);

-- insert data to 'discounts'
INSERT INTO car_shop.discounts(sale_id, discount)
SELECT car_shop.sales.sale_id, (raw_data.sales.discount::REAL / 100)::NUMERIC(2, 2)
  FROM car_shop.sales
           INNER JOIN car_shop.cars USING (car_id)
           INNER JOIN car_shop.models USING (model_id)
           INNER JOIN car_shop.brands USING (brand_id)
           INNER JOIN car_shop.colors USING (color_id)
           INNER JOIN car_shop.persons USING (person_id)
           INNER JOIN raw_data.sales ON auto = CONCAT(car_shop.brands.name, ' ', car_shop.models.name, ', ', car_shop.colors.name)
      AND raw_data.sales.person_name = CONCAT_WS(' ', car_shop.persons.appeal, car_shop.persons.first_name, car_shop.persons.last_name, car_shop.persons.degrees)
      AND car_shop.sales.sale_date = raw_data.sales.date;

-- remove 'raw_data'
DROP TABLE raw_data.sales;
DROP SCHEMA raw_data;

-- solution for task 1
SELECT (1 - COUNT(gasoline_consumption) / COUNT(*)::REAL) * 100 AS electric_vehicle_percents
  FROM car_shop.models;

-- solution for task 2
SELECT brands.name, EXTRACT(YEAR FROM sales.sale_date) AS year, ROUND(AVG(sales.price), 2) AS price_avg
  FROM car_shop.brands
           INNER JOIN car_shop.models USING (brand_id)
           INNER JOIN car_shop.cars USING (model_id)
           INNER JOIN car_shop.sales USING (car_id)
 GROUP BY brands.name, year
 ORDER BY brands.name, year;

-- solution for task 3
SELECT EXTRACT(MONTH FROM sale_date) AS month, EXTRACT(YEAR FROM sale_date) AS year, ROUND(AVG(price), 2) AS price_avg
  FROM car_shop.sales
 WHERE EXTRACT(YEAR FROM sale_date) = 2022
 GROUP BY month, year
 ORDER BY month;

-- solution for task 4
SELECT CONCAT_WS(' ', car_shop.persons.appeal, car_shop.persons.first_name, car_shop.persons.last_name, car_shop.persons.degrees) AS person,
       STRING_AGG(CONCAT_WS(' ', car_shop.brands.name, car_shop.models.name), ', ')                                               AS cars
  FROM car_shop.persons
           INNER JOIN car_shop.sales USING (person_id)
           INNER JOIN car_shop.cars USING (car_id)
           INNER JOIN car_shop.models USING (model_id)
           INNER JOIN car_shop.brands USING (brand_id)
 GROUP BY person
 ORDER BY person;

-- solution for task 5
SELECT countries.name                                                AS brand_origin,
       MAX(car_shop.sales.price / (1 - car_shop.discounts.discount)) AS price_max,
       MIN(car_shop.sales.price / (1 - car_shop.discounts.discount)) AS price_min
  FROM car_shop.countries
           INNER JOIN car_shop.brands USING (country_id)
           INNER JOIN car_shop.models USING (brand_id)
           INNER JOIN car_shop.cars USING (model_id)
           INNER JOIN car_shop.sales USING (car_id)
           INNER JOIN car_shop.discounts USING (sale_id)
 GROUP BY countries.name;

-- solution for task 6 (US phone starts with +1 or 100, not only +1)
SELECT COUNT(country_code) AS persons_from_usa_count
  FROM car_shop.phones
 WHERE country_code = '+1'
    OR country_code = '100';