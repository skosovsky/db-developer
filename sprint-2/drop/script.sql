-- удаление таблицы
DROP TABLE IF EXISTS store.products;

-- удаление схемы с таблицами
DROP SCHEMA IF EXISTS store CASCADE;

-- удаление базы данных
DROP DATABASE IF EXISTS shop WITH (FORCE);