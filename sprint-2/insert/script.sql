-- создаем таблицу
CREATE TABLE users (
    PRIMARY KEY (id),
    id         SERIAL,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(100) NOT NULL
        UNIQUE,
    phone      VARCHAR(30),
    birthday   DATE,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
        CHECK (deleted_at >= created_at)
);

-- добавим запись
INSERT INTO users (name, email, phone)
VALUES ('Ивано Иван Иванович', 'ivanov@yandex.ru', '+7 (495) 123-56-78');

-- добавляем запись с DEFAULT
INSERT INTO users (id, name, phone, email, birthday, created_at)
VALUES (DEFAULT, -- значение по умолчанию для SERIAL - автоинкрекмент
        'Петрова Ольга Петровна',
        '+7 (495) 236-56-98',
        'o.petrova@yandex.ru',
        '2001-05-06',
        DEFAULT -- значение по умолчанию - текущий момент времени
       );

-- добавим сразу 3 записи
INSERT INTO users (name, email, phone)
VALUES ('Петров Сергей Петрович', 'petrov@yandex.ru', '+7 (495) 123-56-78'),
       ('Зайцева Елена Ивановна', 'zayceva@yandex.ru', '+7 (495) 345-86-98'),
       ('Медведев Семён Семёнович', 'medvedev@yandex.ru', '+7 (495) 369-85-12');

-- добавим еще 1 запись, без указания полей
INSERT INTO users
VALUES (DEFAULT, -- id
        'Кузнецов Сергей Алексеевич', -- name
        'kuznetzov@yandex.ru', -- email
        '+7 (495) 316-64-80', -- phone
        '1985-03-16', -- birthday
        DEFAULT, -- значение по умолчанию - текущий момент времени
        NULL -- NULL для колонки deleted_at
       );

-- проверим что получилось
SELECT *
  FROM users;

