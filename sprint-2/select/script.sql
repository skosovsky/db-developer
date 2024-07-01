-- получение значений
SELECT name, phone
  FROM users;

-- получение всех полей
SELECT *
  FROM users;

-- получение полей с условием
SELECT phone
  FROM users
 WHERE name = 'Иванов Иван Иванович';

-- имена и дни рождения пользователей, у которых отсутствует дата удаления
SELECT name, birthday
  FROM users
 WHERE deleted_at IS NULL;