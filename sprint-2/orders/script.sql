-- создание новой таблицы
CREATE TABLE IF NOT EXISTS service_points (
    PRIMARY KEY (id),
    id         SERIAL,
    name       TEXT NOT NULL,
    email      TEXT NOT NULL,
    phone      TEXT NOT NULL,
    address    TEXT NOT NULL,
    manager    TEXT NOT NULL,
    opens_at   TIME NOT NULL,
    closes_at  TIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- добавление нового поля days_off
ALTER TABLE service_points
    ADD COLUMN days_off TEXT NULL;

-- добавление ограничения по времени открытия
ALTER TABLE service_points
    ADD CONSTRAINT check_close_time
        CHECK (closes_at > opens_at);

-- исправить ошибки
CREATE TABLE suppliers (
    PRIMARY KEY (id),
    id             SERIAL,
    name           TEXT NOT NULL
        UNIQUE,
    email          TEXT NOT NULL,
    phone          TEXT NOT NULL,
    address        TEXT NOT NULL,
    contact_person TEXT,
    bank_name      TEXT,
    bank_account   TEXT,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE suppliers
    ADD COLUMN comments TEXT,
    ADD COLUMN debt     DECIMAL(12, 2);