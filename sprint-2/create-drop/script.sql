-- Создайте базу данных test_db.
CREATE DATABASE test_db;

-- Переключиться на базу test_db
-- Внутри test_db создайте схемы test_schema_1 и test_schema_2.
CREATE SCHEMA IF NOT EXISTS test_schema_1;
CREATE SCHEMA IF NOT EXISTS test_schema_2;

-- Внутри схем создайте таблицы: a. test_schema_1.table_1 с полями id (INTEGER, автоинкремент, PK) и name (TEXT не пустое), b. test_schema_2.table_1 с полями id (INTEGER, автоинкремент, PK) и name (TEXT не пустое), created_at (TIMESTAMP не пустое, значение по умолчанию - текущие дата и время).
CREATE TABLE IF NOT EXISTS test_schema_1.table_1 (
    PRIMARY KEY (id),
    id   SERIAL,
    name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS test_schema_2.table_1 (
    PRIMARY KEY (id),
    id         SERIAL,
    name       TEXT      NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Удалите таблицу test_schema_2.table_1.
DROP TABLE IF EXISTS test_schema_2.table_1;

-- Удалите схему test_schema_2.
DROP SCHEMA IF EXISTS test_schema_2;

-- Удалите схему test_schema_1, включая все таблицы в ней.
DROP SCHEMA IF EXISTS test_schema_1 CASCADE;

-- Выйти из подключения к базе и переключиться на базу postgres.
-- Удалите базу данных test_db.
DROP DATABASE IF EXISTS test_db;

-- Если не удается выключить по хорошему, делаем это принудительно.
DROP DATABASE IF EXISTS test_db WITH (FORCE);