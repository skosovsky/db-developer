-- создание проверки с ограничениями
CREATE TABLE store.products (
    name        VARCHAR(255),
    description TEXT,
    price       NUMERIC(9, 2)
        CHECK (price > 0),
    amount      INTEGER   NOT NULL DEFAULT 0
        CHECK (amount >= 0),
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at  TIMESTAMP NULL
        CHECK (deleted_at >= products.created_at)
);

-- удаление таблицы
DROP TABLE store.products;