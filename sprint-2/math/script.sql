-- создаем виртуальную таблицу, псевдонимы таблицу и стаолбцу
SELECT number, ABS(number)
  FROM (VALUES (10), (-10))
           AS examples(number);

-- или так
SELECT number, @number
  FROM (VALUES (10), (-10))
           AS examples(number);

-- округление в большую, меньшую сторону, ближайшего целого числа
SELECT number, FLOOR(number), CEILING(number), ROUND(number)
  FROM (VALUES (20.23), (-20.23))
           AS examples(number);

-- или усечем значения (без округления, отбросим)
SELECT TRUNC(21.5595743, 2);

-- возведем в степень
SELECT number, POWER(number, 2)
  FROM (VALUES (2), (451), (3.14), (-273.15))
           AS examples(number);

-- или
SELECT number, number ^ 2
  FROM (VALUES (2), (4))
           AS examples(number);

-- или корень квадратный
SELECT number, SQRT(ABS(number))::REAL
  FROM (VALUES (4), (-16), (17.64))
           AS examples(number);

-- вывести случайное значение
SELECT RANDOM(), RANDOM(), TRUNC(RANDOM() * 10)::INT % 10;
