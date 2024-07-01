-- создание таблицы customers
CREATE TABLE IF NOT EXISTS customers (
    PRIMARY KEY (id),
    id         SERIAL,
    name       TEXT NOT NULL,
    email      TEXT NOT NULL,
    created_at TIMESTAMP
);

-- создание еще одной таблицы customers
CREATE TABLE IF NOT EXISTS customers (
    PRIMARY KEY (id),
    id         SERIAL,
    name       TEXT      NOT NULL,
    email      TEXT      NOT NULL,
    phone      TEXT      NOT NULL,
    address    TEXT      NOT NULL,
    birthday   DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- еще одно улучшение таблицы customers
CREATE TABLE IF NOT EXISTS customers (
    PRIMARY KEY (id),
    id         SERIAL,
    name       TEXT NOT NULL,
    email      TEXT NOT NULL
        UNIQUE,
    phone      TEXT NOT NULL,
    address    TEXT NOT NULL,
    birthday   DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (phone, address)
);

-- исправить ошибку
CREATE TABLE IF NOT EXISTS orders (
    PRIMARY KEY (id),
    id          SERIAL,
    customer_id INTEGER       NOT NULL,
    amount      NUMERIC(9, 2) NOT NULL DEFAULT 0,
    paid        BOOLEAN       NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP              DEFAULT CURRENT_TIMESTAMP
);

-- добавить проверку
CREATE TABLE IF NOT EXISTS orders (
    PRIMARY KEY (id),
    id          SERIAL,
    customer_id INTEGER       NOT NULL,
    amount      NUMERIC(9, 2) NOT NULL DEFAULT 0
        CHECK (amount >= 0),
    paid        BOOLEAN       NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP              DEFAULT CURRENT_TIMESTAMP
);