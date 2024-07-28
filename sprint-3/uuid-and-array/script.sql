-- добавить значения в таблицу vendors
INSERT INTO vendors (guid, name, inn)
VALUES (gen_random_uuid(), 'ООО «Буренка»', 7777123456);

-- добавить данные о выручке
INSERT INTO week_revenue (date_begin, revenue)
VALUES ('2023-08-14', ARRAY [[120,79,98],[98,60,101],[100,75,103],[101,68,93],[139,90,105],[130,81,87],[115,80,100]]);

-- найти выручку
SELECT revenue[4][3]
  FROM week_revenue
 WHERE date_begin = '2023-08-07';

-- определить кол-во дней
SELECT COUNT(*)
  FROM (SELECT UNNEST(revenue[1:7][2:2]) AS revenue
          FROM week_revenue
         WHERE date_begin = '2023-08-07') t
 WHERE t.revenue > 80;

-- определить количество дней
SELECT ARRAY_LENGTH(revenue, 1)
  FROM week_revenue
 WHERE date_begin = '2023-08-28';

-- определить количество дней с выручкой
SELECT *
FROM week_revenue
WHERE 140 > ANY(revenue);