-- структура компании
CREATE TABLE company_org (
    PRIMARY KEY (id),
    id            INTEGER,
    parent_id     INTEGER,
    position_name VARCHAR(50) NOT NULL,
    full_name     VARCHAR(50) NOT NULL
);

INSERT INTO company_org (id, parent_id, position_name, full_name)
VALUES (1, NULL, 'Руководитель организации', 'Голованов А.А.'),
       (2, 1, 'Руководитель проектного офиса', 'Иванов Б.И.'),
       (3, 1, 'Руководитель отдела разработки', 'Соколов Е.В.'),
       (4, 2, 'Менеджер проектов', 'Пушкина Д.Ф.'),
       (5, 2, 'Менеджер проектов', 'Петров У.В.'),
       (6, 3, 'Старший разработчик', 'Вовченко П.Г.'),
       (7, 3, 'Ведущий тестировщик', 'Семёнов Р.В.'),
       (8, 6, 'Разработчик', 'Коротков И.Д.'),
       (9, 6, 'Разработчик', 'Зимарин Н.Л.'),
       (10, 6, 'Аналитик', 'Аксёнова Н.Д.'),
       (11, 7, 'Тестировщик', 'Борисов М.Ю.'),
       (12, 7, 'Тестировщик', 'Цветкова Л.О.');

-- выведем сотрудников отдела разработки
-- руководитель
  WITH dev_department AS (SELECT id, parent_id, position_name, full_name
                            FROM company_org
                           WHERE id = 3)
SELECT *
  FROM dev_department;

-- сотрудники руководителя
  WITH RECURSIVE dev_department AS (SELECT id, parent_id, position_name, full_name
                                      FROM company_org
                                     WHERE id = 3
                                     UNION ALL
                                    SELECT company_org.id,
                                           company_org.parent_id,
                                           company_org.position_name,
                                           company_org.full_name
                                      FROM company_org
                                               INNER JOIN dev_department ON company_org.parent_id = dev_department.id)
SELECT *
  FROM dev_department;

-- вывод с уровнем иерархии
  WITH RECURSIVE dev_department AS (SELECT id, parent_id, 1 AS level, position_name, full_name
                                      FROM company_org
                                     WHERE id = 3
                                     UNION ALL
                                    SELECT company_org.id,
                                           company_org.parent_id,
                                           level + 1,
                                           company_org.position_name,
                                           company_org.full_name
                                      FROM company_org
                                               INNER JOIN dev_department ON company_org.parent_id = dev_department.id)
SELECT *
  FROM dev_department
 ORDER BY level;

-- вывод с пути
  WITH RECURSIVE dev_department AS (SELECT id, parent_id, 1 AS level, position_name, full_name, full_name::TEXT full_path
                                      FROM company_org
                                     WHERE id = 3
                                     UNION ALL
                                    SELECT company_org.id,
                                           company_org.parent_id,
                                           level + 1,
                                           company_org.position_name,
                                           company_org.full_name,
                                           CONCAT(dev_department.full_path, '-', company_org.full_name) AS full_path
                                      FROM company_org
                                               INNER JOIN dev_department ON company_org.parent_id = dev_department.id)
SELECT *
  FROM dev_department
 ORDER BY full_path;

-- тестовый запрос
  WITH RECURSIVE subordinates AS (SELECT id, parent_id
                                    FROM company_org
                                   UNION ALL
                                  SELECT subordinates.id, company_org.parent_id
                                    FROM company_org
                                             JOIN subordinates ON company_org.id = subordinates.parent_id)
SELECT company_org.id, company_org.full_name, COUNT(subordinates.id) AS total
  FROM company_org
           LEFT JOIN subordinates ON company_org.id = subordinates.parent_id
 GROUP BY company_org.id, company_org.full_name
 ORDER BY total DESC
 LIMIT 3;

-- список всех продуктов компании
CREATE TABLE products (
    PRIMARY KEY (id),
    id           INTEGER,
    parent_id    INTEGER      NULL,
    product_name VARCHAR(100) NOT NULL
);

INSERT INTO products (id, parent_id, product_name)
VALUES (1, NULL, 'Частное лицо'),
       (2, 1, 'Авто'),
       (3, 2, 'КАСКО'),
       (4, 1, 'Имущество'),
       (5, 4, 'Имущество ФЛ'),
       (6, 2, 'Зелёная Карта'),
       (7, 1, 'Здоровье'),
       (8, 7, 'Несчастные случаи (НС)'),
       (9, 7, 'ДМС'),
       (10, 2, 'Несчастные случаи (НС)'),
       (1035, 3, 'К. Автокаско граждан, 10'),
       (1036, 3, 'К. Автокаско граждан, 30'),
       (1037, 3, 'К. Автокаско граждан, 30.2'),
       (1038, 3, 'К. Автокаско граждан, 30.3'),
       (1039, 3, 'К. Автокаско граждан, 30.4'),
       (1040, 3, 'К. Автокаско граждан, 125'),
       (1041, 3, 'К. Автокаско граждан, 125.3'),
       (1042, 3, 'К. Автокаско граждан, 171'),
       (1043, 3, 'К. Автокаско граждан, 125.4'),
       (1044, 3, 'К. Автокаско граждан, 171/1'),
       (1045, 3, 'К. Автокаско граждан,156.1'),
       (1436, 5, 'Е. Имущество граждан, 19'),
       (1437, 5, 'Е. Имущество граждан, 100'),
       (1438, 5, 'Е. Имущество граждан, 121'),
       (1439, 5, 'Е. Имущество граждан, 19/1'),
       (1440, 5, 'Е. Имущество граждан, 100/1'),
       (1441, 5, 'Е. Имущество граждан, 100/2'),
       (1442, 5, 'Е. Имущество граждан, 151'),
       (1443, 5, 'Е. Имущество граждан, 100/3'),
       (1689, 5, 'Е. Имущество граждан, 199'),
       (1423, 5, 'И. Строения граждан, 20'),
       (1424, 5, 'И. Строения граждан, 100'),
       (1476, 5, 'U. Страхование риска утраты права собственности, 58'),
       (1477, 5, 'U. Страхование риска утраты права собственности, 119'),
       (1478, 5, 'U. Страхование риска утраты права собственности, 123'),
       (1449, 5, 'Я. Страхование муниципального жилья, 61'),
       (1450, 5, 'Я. Страхование муниципального жилья, 86'),
       (1451, 5, 'Я. Страхование муниципального жилья, 20/1 (Я)'),
       (1597, 6, '2. Зелёная карта ФЛ, 131'),
       (1073, 8, 'J. Клиент на границе "Н/С в А/М", 30 (J)'),
       (1074, 8, 'J. Клиент на границе "Н/С в А/М", 30.2 (J)'),
       (1075, 8, 'J. Клиент на границе "Н/С в А/М", 30.3 (J)'),
       (1076, 8, 'J. Клиент на границе "Н/С в А/М", 5 (П)'),
       (1063, 10, 'W. Авто Н/С, 125'),
       (1064, 10, 'W. Авто Н/С, 30 (W)'),
       (1065, 10, 'W. Авто Н/С, 30.2 (W)'),
       (1066, 10, 'W. Авто Н/С, 30.3 (W)'),
       (1067, 10, 'W. Авто Н/С, 125.2'),
       (1566, 9, 'Y. Добровольное страхование пассажиров, 68/1 (П/В)'),
       (1567, 9, 'Y. Добровольное страхование пассажиров, 68/1 (П/Ж)'),
       (1568, 9, 'Y. Добровольное страхование пассажиров, 68/1 (П/М)'),
       (1569, 9, 'Y. Добровольное страхование пассажиров, 68'),
       (1508, 8, 'П. Страхование от н/с в т.ч. тяжелых болезней за счет ФЛ, 138'),
       (1509, 8, 'П. Страхование от н/с в т.ч. тяжелых болезней за счет ФЛ, 145'),
       (1510, 8, 'П. Страхование от н/с в т.ч. тяжелых болезней за счет ФЛ, 149'),
       (1511, 8, 'П. Страхование от н/с в т.ч. тяжелых болезней за счет ФЛ, 2 (П)'),
       (1572, 8, 'Р. Н/С и болезни граждан, выезжающих с МПП, 7'),
       (1573, 8, 'Р. Н/С и болезни граждан, выезжающих с МПП, 60.4'),
       (1574, 8, 'Р. Н/С и болезни граждан, выезжающих с МПП, 60.5'),
       (1555, 8, 'Т. Об. страх. пассаж. автотрансп. средств, 8 (Т/1)'),
       (1556, 8, 'Т. Об. страх. пассаж. автотрансп. средств, 8 (Т/2)'),
       (1558, 8, 'У. Об. страх. пассаж. морс. и речн. транспорта, 8 (У/1)'),
       (1717, 7, 'Страхование жизни'),
       (1559, 8, 'У. Об. страх. пассаж. морс. и речн. транспорта, 8 (У/2)'),
       (1237, 8, 'Ъ. Н/С авиапассажиров, 6 (Ъ)'),
       (1238, 8, 'Ъ. Н/С авиапассажиров, 68 (Ъ)'),
       (1239, 8, 'Ъ. Н/С авиапассажиров, 68/1 (Ъ)'),
       (1653, 8, 'Ъ. Н/С пассажиров, 68'),
       (1241, 8, 'V. Авиа Н/С, 2 (V)'),
       (1242, 8, 'V. Авиа Н/С, 5 (V)'),
       (1650, 8, 'V. Авиа Н/С, 5'),
       (1686, 8, 'V. Авиа Н/С, 83'),
       (1700, 1, 'Путешествия'),
       (1701, 1700, 'Путешествия за границу'),
       (1702, 1701, 'Путешествие за границу, 150'),
       (1703, 1701, 'Путешествие за границу, 200 (V)'),
       (1704, 1701, 'Путешествие за границу, 250 (V)'),
       (1705, 1700, 'Путешествие по России'),
       (1706, 1705, 'Путешествие по России, 100'),
       (1707, 1705, 'Путешествие по России, 150 (V)'),
       (1708, 1705, 'Путешествие по России, 200 (V)'),
       (1709, 7, 'Страхование здоровья путешественников'),
       (1710, 1709, 'Страхование здоровья путешественников, 100 (П/В)'),
       (1711, 1709, 'Страхование здоровья путешественников, 150 (П/В)'),
       (1712, 1709, 'Страхование здоровья путешественников, 200 (П/Ж)'),
       (1713, 7, 'Страхование от несчастного случая'),
       (1714, 1713, 'Страхование от несчастного случая, 100'),
       (1715, 1713, 'Страхование от несчастного случая, 150'),
       (1716, 1713, 'Страхование от несчастного случая, 200 (П/Ж)'),
       (1718, 1717, 'Страхование жизни, 100'),
       (1719, 1717, 'Страхование жизни, 150 (П/Ж)'),
       (1720, 1717, 'Страхование жизни, 200'),
       (1721, 7, 'Страхование имущества'),
       (1722, 1721, 'Страхование квартиры'),
       (1723, 1722, 'Страхование квартиры, 100/1'),
       (1724, 1722, 'Страхование квартиры, 100/2'),
       (1725, 1722, 'Страхование квартиры, 200'),
       (1726, 1721, 'Страхование дома'),
       (1727, 1726, 'Страхование дома, 100/1'),
       (1728, 1726, 'Страхование дома, 100/2'),
       (1729, 1726, 'Страхование дома, 200'),
       (1730, 7, 'Страхование автомобиля'),
       (1731, 1730, 'Страхование автомобиля, 100/1'),
       (1732, 1730, 'Страхование автомобиля, 100/2'),
       (1733, 1730, 'Страхование автомобиля, 200'),
       (1734, 7, 'Страхование от несчастного случая на работе'),
       (1735, 1734, 'Страхование от несчастного случая на работе, 100'),
       (1736, 1734, 'Страхование от несчастного случая на работе, (P/1)'),
       (1737, 1734, 'Страхование от несчастного случая на работе, 50 (P/1)'),
       (1738, 7, 'Страхование от пожара'),
       (1739, 1738, 'Страхование от пожара, 100'),
       (1740, 1738, 'Страхование от пожара, 100/P'),
       (1741, 1738, 'Страхование от пожара, 100/M');

  WITH RECURSIVE prod AS (SELECT id, parent_id, product_name
                            FROM products
                           WHERE id = 5
                           UNION ALL
                          SELECT products.id, products.parent_id, products.product_name
                            FROM products
                                     INNER JOIN prod ON products.parent_id = prod.id)
SELECT *
  FROM prod
 WHERE id <> 5;

-- список всех продуктов категории Авто и столбец для наглядности
  WITH RECURSIVE prod AS (SELECT id, parent_id, 1 AS level, product_name, product_name::TEXT AS full_path
                            FROM products
                           WHERE id = 2
                           UNION ALL
                          SELECT products.id,
                                 products.parent_id,
                                 level + 1,
                                 products.product_name,
                                 CONCAT(prod.full_path, '-', products.product_name) AS full_path
                            FROM products
                                     INNER JOIN prod ON products.parent_id = prod.id)
SELECT *
  FROM prod
 ORDER BY full_path;

-- Полный путь к продукту
WITH RECURSIVE product_path AS
(
    SELECT id, parent_id, product_name::TEXT full_path
    FROM products
    WHERE product_name = '2. Зелёная карта ФЛ, 131'
    UNION ALL
    SELECT products.id, products.parent_id, CONCAT(product_path.full_path, '-', products.product_name) AS full_path
    FROM products
    INNER JOIN product_path ON products.id = product_path.parent_id
)
SELECT full_path
FROM product_path
WHERE parent_id IS NULL;