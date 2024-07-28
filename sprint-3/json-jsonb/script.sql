-- добавим json
ALTER TABLE drivers
    ADD COLUMN worksheet_json JSON;
ALTER TABLE drivers
    ADD COLUMN worksheet_jsonb JSONB;

-- вставим данныен
INSERT INTO drivers (name, license, depot_id, worksheet_json, worksheet_jsonb)
VALUES ('Колесов Игорь Витальевич', 7777123123, 1,
        '{
          "name": "Колесов Игорь Витальевич",
          "birth_date": "12.06.1985",
          "children": [
            {
              "relationship": "сын",
              "name": "Колесов Артем"
            },
            {
              "relationship": "дочь",
              "name": "Колесова Инна"
            }
          ]
        }',
        '{
          "name": "Колесов Игорь Витальевич",
          "birth_date": "12.06.1985",
          "children": [
            {
              "relationship": "сын",
              "name": "Колесов Артем"
            },
            {
              "relationship": "дочь",
              "name": "Колесова Инна"
            }
          ]
        }');

-- пример работы встроенных функций json
SELECT JSON_BUILD_OBJECT('name', 'Колесов Игорь Вительевич',
                         'birth_date', '12.06.1985',
                         'children', JSON_BUILD_ARRAY(
                                 JSON_BUILD_OBJECT('relationship', 'сын', 'name', 'Колесов Артем'),
                                 JSON_BUILD_OBJECT('relationship', 'дочь', 'name', 'Колесова Инна')));

-- извлечение данных
SELECT '{
  "name": "Колесов Игорь Витальевич",
  "children": [
    {
      "relationship": "сын",
      "name": "Колесов Артем"
    },
    {
      "relationship": "дочь",
      "name": "Колесова Инна"
    }
  ],
  "birth_date": "12.06.1985"
}'::JSONB -> 'name';

SELECT '{
  "name": "Колесов Игорь Витальевич",
  "children": [
    {
      "relationship": "сын",
      "name": "Колесов Артем"
    },
    {
      "relationship": "дочь",
      "name": "Колесова Инна"
    }
  ],
  "birth_date": "12.06.1985"
}'::JSONB ->> 'name';

-- поиск в массивах JSON по индексу
SELECT '{
  "name": "Колесов Игорь Витальевич",
  "children": [
    {
      "relationship": "сын",
      "name": "Колесов Артем"
    },
    {
      "relationship": "дочь",
      "name": "Колесова Инна"
    }
  ],
  "birth_date": "12.06.1985"
}'::JSONB -> 'children' -> 0;

-- поиск по пути
SELECT '{
  "name": "Иван",
  "education": {
    "year": 1995,
    "school": "экономика и право"
  }
}'::JSONB #>> '{education, year}';

-- поиск по пути в массиве
SELECT '{
  "name": "Иван",
  "education": {
    "year": 1995,
    "school": "экономика и право"
  },
  "children": [
    "Таня",
    "Ваня"
  ]
}'::JSONB #>> '{children, 0}';

-- проверка
SELECT '{
  "title": "Война и мир",
  "author": "Толстой Л.Н.",
  "published": 1985,
  "characters": [
    {
      "name": "Наташа Ростова",
      "dignity": "графиня"
    },
    {
      "name": "Пьер Безухов",
      "dignity": "граф"
    },
    {
      "name": "Андрей Болконский",
      "dignity": "князь"
    }
  ]
}'::JSONB -> 'characters' -> 1 -> 'name';

SELECT '[
  {
    "name": "Наташа Ростова",
    "dignity": "графиня"
  },
  {
    "name": "Пьер Безухов",
    "dignity": "граф"
  },
  {
    "name": "Андрей Болконский",
    "dignity": "князь"
  }
]'::JSONB - 3;

-- добавить сертификат
INSERT INTO conformity_certs (product_id, cert)
SELECT id,
       '{
         "product_name": "чай матча",
         "date": "23.07.2023",
         "signed": [
           "Морковкин А.А.",
           "Зеленая Е.А."
         ],
         "weight": 200,
         "country": "Вьетнам"
       }'::JSONB
  FROM products
 WHERE name = 'матча';

-- найти значение в сертификате
SELECT cert -> 'certifications' -> -1 ->> 'result'
  FROM conformity_certs
 WHERE product_id = (SELECT id
                       FROM products
                      WHERE name = 'сельдерей');

-- проверить сколько человек подписали сертификат
SELECT JSONB_ARRAY_LENGTH(cert -> 'signed')
  FROM conformity_certs
 WHERE product_id = (SELECT id
                       FROM products
                      WHERE name = 'миндальное молоко');

-- изменить номер сертификата
UPDATE conformity_certs
   SET cert = JSONB_SET(cert, '{cert_number}', '123456')
 WHERE product_id = (SELECT id
                       FROM products
                      WHERE name = 'миндальное молоко');

-- изменить номер в сертификате
UPDATE conformity_certs
   SET cert = JSONB_SET(cert, '{certifications, 0, number}', '101')
 WHERE product_id = (SELECT id
                       FROM products
                      WHERE name = 'сельдерей');

-- дополнить сертификат
UPDATE conformity_certs
   SET cert = cert || '{"country": "Россия" }'
 WHERE product_id = (SELECT id
                       FROM products
                      WHERE name = 'сельдерей');

-- удаление поля из JSON
UPDATE conformity_certs
   SET cert = cert - 'signed'
 WHERE product_id = (SELECT id
                       FROM products
                      WHERE name = 'миндальное молоко');