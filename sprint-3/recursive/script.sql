-- генерация от 1 до 100 рекурсией
  WITH RECURSIVE test_data AS (SELECT 1 AS num
                                UNION ALL
                               SELECT num + 1
                                 FROM test_data
                                WHERE num < 100)
SELECT num
  FROM test_data;

-- генерация случайных значений рекурсией
  WITH RECURSIVE test_data AS (SELECT FLOOR(RANDOM() * 100) AS num
                                UNION ALL
                               SELECT FLOOR(RANDOM() * 100) AS num
                                 FROM test_data)
SELECT num
  FROM test_data
 LIMIT 100;

-- генерация 100 строк
  WITH RECURSIVE numbers AS (SELECT 1 AS row_num, 1 AS row_sum
                              UNION ALL
                             SELECT row_num + 1, row_sum + row_num + 1
                               FROM numbers
                              WHERE row_num < 100)
SELECT row_num, row_sum
  FROM numbers;

-- генерация числа фибоначи не больше 2000
  WITH RECURSIVE numbers AS (SELECT 0 AS fibonacci_number, 1 AS temp_number
                              UNION ALL
                             SELECT temp_number, fibonacci_number + temp_number
                               FROM numbers
                              WHERE temp_number < 2000)
SELECT fibonacci_number
  FROM numbers;