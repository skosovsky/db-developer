-- создание таблицы с пользователями
CREATE TABLE IF NOT EXISTS users (
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(100),
    phone      VARCHAR(30),
    birthday   DATE,
    created_at TIMESTAMP,
    deleted_at TIMESTAMP
);

-- добавляем поле адрес
ALTER TABLE users
    ADD COLUMN address TEXT;

-- поменяем тип столбца
ALTER TABLE users
    ALTER COLUMN address TYPE VARCHAR(300);

-- удаляем столбец
ALTER TABLE users
    DROP COLUMN phone;

-- добавляем ограничения NON NULL
ALTER TABLE users
    ADD COLUMN phone VARCHAR(30);

ALTER TABLE users
    ALTER COLUMN phone SET NOT NULL;

-- убираем ограничение NOT NULL
ALTER TABLE users
    ALTER COLUMN phone DROP NOT NULL;

-- добавляем уникальность одному столбцу
ALTER TABLE users
    ADD UNIQUE (phone);

-- и даем имя уникальности
ALTER TABLE users
    ADD CONSTRAINT users_phone_unique
        UNIQUE (phone);

-- добавляем уникальность на 2 столбца (создаем их)
ALTER TABLE users
    ADD COLUMN passport_series VARCHAR(5),
    ADD COLUMN passport_number VARCHAR(6);

ALTER TABLE users
    ADD UNIQUE (passport_series, passport_number);

-- убираем уникальность одному столбцу
ALTER TABLE users
    DROP CONSTRAINT users_phone_key;

-- настраиваем первичный ключ
ALTER TABLE users
    ADD PRIMARY KEY (name);

-- удаляем первичный ключ
ALTER TABLE users
    DROP CONSTRAINT users_pkey;