-- нумерация строк
SELECT *, ROW_NUMBER() OVER ()
  FROM online_store.orders
 LIMIT 10;

-- нумерация строк с сортировкой
SELECT *, ROW_NUMBER() OVER ()
  FROM online_store.orders
 ORDER BY user_id
 LIMIT 10;

-- с сортировкой внутри
SELECT *, ROW_NUMBER() OVER (ORDER BY user_id)
  FROM online_store.orders
 ORDER BY user_id
 LIMIT 10;

-- все поля с рангом
SELECT *, ROW_NUMBER() OVER ()
  FROM tools_shop.items;

-- проранжируйте и выведите 1 запись
  WITH users AS (SELECT *,
                        ROW_NUMBER() OVER (ORDER BY created_at) AS idx
                   FROM tools_shop.users)
SELECT user_id
  FROM users
 WHERE idx = 2021;

--- проранжируйте по дате заказа и выведите 1 запись
  WITH orders AS (SELECT *,
                         ROW_NUMBER() OVER (ORDER BY paid_at DESC) AS idx
                    FROM tools_shop.orders)
SELECT total_amt
  FROM orders
 WHERE idx = 50;

-- выведите список уникальных пользователей, которые совершили 3 и более заказа
SELECT DISTINCT uniq_users.user_id
  FROM (SELECT user_id, ROW_NUMBER() OVER (PARTITION BY user_id) AS counter
          FROM tools_shop.orders) AS uniq_users
 WHERE uniq_users.counter >= 3;

-- проранжируйте записи, одинаковые записи с одинаковым рангом
SELECT *, RANK() OVER (ORDER BY item_id)
  FROM tools_shop.order_x_item;

-- проранжируйте записи
SELECT *, DENSE_RANK() OVER (ORDER BY created_at DESC )
  FROM tools_shop.users;