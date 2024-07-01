--- вставим данные
INSERT INTO suppliers (name, address, phone, email, contact_person, bank_name, bank_account)
VALUES ('ООО «Птичка»', 'г. Москва, ул. 3-я Ямская, д. 345', '687-44-55', 'contact@ptichka.ru',
        'Голубев Антон Игоревич', 'ООО «МКБ»', '40801234567890');

-- вставим 2 записи
INSERT INTO customers (name, email, phone, address, birthday)
VALUES ('Егоров Алексей', 'egorov.a@mail.ru', '+7(912)0764567', 'Калуга, Садовая ул. 75/101', '1994-08-09'),
       ('Смирнова Светлана', 'sveta2000@yandex.ru', '810 34-345-88', 'Киров, пл. Свободы 3б, кв. 17', NULL);

-- и еще 3 записи
INSERT INTO products (name, category, price, amount, description, origin_country, code)
VALUES ('Туфли женские', 'Обувь', 3200, 10, 'Натуральная кожа. Производство г. Калуга', 'Россия', 'ОЖТ098057483'),
       ('Сандалии мужские', 'Обувь', 2800, DEFAULT, 'Ткань. Искусственная кожа.', 'Китай', 'ОМС789030456'),
       ('Кроссовки детские', 'Обувь', 1200, 20, 'Серия «Маша и Медведь»', 'Россия', 'ОДК456787651');