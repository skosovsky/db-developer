-- создаем таблицу
CREATE TABLE stock (
    name      TEXT    NOT NULL,
    stock_in  INTEGER NOT NULL,
    stock_out INTEGER NOT NULL
);

-- добавляем данные
INSERT INTO stock (name, stock_in, stock_out)
VALUES ('Ремешок силиконовый для часов', 60, 20),
       ('Ремешок для часов кожаный', 33, 12);

-- рассчитаем данные c CAST
SELECT name,
       stock_out,
       stock_in,
       CAST(stock_out AS REAL) / stock_in
  FROM stock;

-- рассчитаем данные в упрощенном виде
SELECT name,
       stock_out,
       stock_in,
       (stock_out::REAL / stock_in)::NUMERIC(3, 2)
  FROM stock;