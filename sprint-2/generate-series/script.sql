-- генерация последовательности
SELECT *
  FROM GENERATE_SERIES(0, 5, 1) AS ascending_seq;

SELECT *
  FROM GENERATE_SERIES(10, 0, -2) AS descending_seq;

SELECT GENERATE_SERIES(10, 0, -2) AS descending_seq;

-- генерируем дробные числа
SELECT GENERATE_SERIES(0.1, 5, 1)    AS seq_1,
       GENERATE_SERIES(15, 0, -2.41) AS seq_2;

-- генерируем строки
SELECT 'order_' || GENERATE_SERIES(1, 5) AS orders;

SELECT CHR(ASCII('A') + GENERATE_SERIES(0, 4))    AS eng,
       CHR(ASCII('Я') - GENERATE_SERIES(0, 8, 2)) AS rus,
       CHR(ASCII('👩') + GENERATE_SERIES(0, 4))    AS smile;

-- генерируем время
SELECT *
  FROM GENERATE_SERIES('2023-05-01 00:00'::TIMESTAMP, '2023-05-03 12:00', '12 hours') AS time_series;

-- генерируем даты
SELECT '2023-05-01'::DATE + GENERATE_SERIES(0, 5) AS dates;

-- генерируем перекрестные множества (за счет двух значений в FROM)
SELECT CHR(ASCII('A') + a) AS first_level,
       b                   AS second_level
  FROM GENERATE_SERIES(0, 2, 1) AS a,
       GENERATE_SERIES(10, 13, 1) AS b;

-- генерируем рандом
SELECT ROUND(RANDOM() * 100) AS random_value
  FROM GENERATE_SERIES(1, 5, 1) AS seq;

SELECT CHR(ASCII('A') + ROUND(RANDOM() * 26)::INTEGER) AS random_letter
  FROM GENERATE_SERIES(1, 5, 1) AS seq;

-- генерируем текст в строку
SELECT STRING_AGG(CHR(65 + FLOOR(RANDOM() * 26)::INTEGER), '') AS random_letter
  FROM GENERATE_SERIES(1, 10) AS num_letters;

-- генерируем несколько строк
SELECT number_of_rows,
       STRING_AGG(CHR(65 + FLOOR(RANDOM() * 26)::INTEGER), '') AS random_letters
  FROM GENERATE_SERIES(1, 5) AS number_of_rows,
       GENERATE_SERIES(1, 10) AS num_of_letters
 GROUP BY number_of_rows;

-- без номера столбцов
SELECT STRING_AGG(CHR(65 + FLOOR(RANDOM() * 26)::INTEGER), '') AS random_letters
  FROM GENERATE_SERIES(1, 10) AS num_of_letters
 GROUP BY GENERATE_SERIES(1, 5);

-- тоже самое но нагляднее
SELECT STRING_AGG(CHR(65 + FLOOR(RANDOM() * 26)::INTEGER), '') AS random_letters
  FROM GENERATE_SERIES(1, 5) AS series1,
       GENERATE_SERIES(1, 10) AS series2
 GROUP BY series1;

-- генерация последовательности случайных дат
SELECT '2023-05-01 00:00'::TIMESTAMP + RANDOM() * ('24 hours'::INTERVAL) AS random_time
  FROM GENERATE_SERIES(1, 5);

SELECT '2023-05-01'::DATE + ROUND(RANDOM() * 10) * ('24 hours'::INTERVAL) AS random_time
  FROM GENERATE_SERIES(1, 10);

SELECT '2023-05-01'::DATE + RANDOM() * 10 * ('24 hours'::INTERVAL) AS random_time
  FROM GENERATE_SERIES(1, 10);

-- генерация при агреации
SELECT movie_year, COUNT(m.film_id) AS movie_num
  FROM GENERATE_SERIES(2000, 2010, 1) AS movie_year
           LEFT JOIN movie AS m ON movie_year = m.release_year
-- присоединит таблицу с данными о фильмах
 GROUP BY movie_year
-- сгруппирует данные по году выпуска фильма
 ORDER BY movie_year;
-- отсортирует вывод в порядке возрастания года выпуска фильма

-- сгенерировать последовательность дат
SELECT '2023-08-01'::DATE + GENERATE_SERIES(0, 31, 3) AS stat_date;
-- или
SELECT GENERATE_SERIES('2023-08-01'::DATE, '2023-08-31', '3 days')::DATE AS stat_date

-- сгенерировать данные для тестирования
SELECT SETSEED(0);
SELECT STRING_AGG(CHR(ASCII('A') + FLOOR(RANDOM() * 26)::INTEGER), '') AS user_id,
       '2023-08-20'::DATE + ROUND(RANDOM() * 10)::INTEGER              AS reg_dt
  FROM GENERATE_SERIES(1, 6) AS char_num,
       GENERATE_SERIES(1, 50) AS line_num
 GROUP BY line_num;

-- сгенерировать данные для запроса
SELECT check_date::DATE,
       CASE
           WHEN SUM(invoice.total) IS NULL THEN 0
           ELSE SUM(invoice.total)
           END AS total_sum
  FROM GENERATE_SERIES('2013-11-01'::DATE, '2013-11-30', '1 day') AS check_date
           LEFT JOIN invoice ON check_date = invoice.invoice_date::DATE
 GROUP BY check_date
 ORDER BY check_date;
