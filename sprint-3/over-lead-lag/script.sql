-- дата прошлого и следуюшего заказа
SELECT user_id,
       event_dt,
       LAG(event_dt) OVER (PARTITION BY user_id ORDER BY event_dt)  AS previous_order_dt,
       LEAD(event_dt) OVER (PARTITION BY user_id ORDER BY event_dt) AS next_order_dt
  FROM online_store.orders
 ORDER BY user_id;

-- посчитать сколько дней прошло с предыдущего заказа
SELECT user_id,
       event_dt,
       LAG(event_dt) OVER (PARTITION BY user_id ORDER BY event_dt)            AS previous_order_dt,
       event_dt - LAG(event_dt) OVER (PARTITION BY user_id ORDER BY event_dt) AS days_from_previous_order
  FROM online_store.orders
 ORDER BY user_id;

-- посчитать прирост пользователей
SELECT session_start::DATE     AS session_date,
       COUNT(DISTINCT user_id) AS users_cnt
  FROM online_store.sessions
 GROUP BY session_date;

-- полный запрос
  WITH users_cnt AS (SELECT session_start::DATE     AS session_date,
                            COUNT(DISTINCT user_id) AS users_cnt
                       FROM online_store.sessions
                      GROUP BY session_date)
SELECT *,
       LAG(users_cnt, 7) OVER (ORDER BY session_date) AS previous_weekday_users_cnt
  FROM users_cnt;

-- если нужно посчитать на сколько
  WITH users_cnt AS (SELECT session_start::DATE     AS session_date,
                            COUNT(DISTINCT user_id) AS users_cnt
                       FROM online_store.sessions
                      GROUP BY session_date)
SELECT *,
       LAG(users_cnt, 7, users_cnt) OVER (ORDER BY session_date)                                    AS previous_weekday_users_cnt,
       ((users_cnt::NUMERIC / LAG(users_cnt, 7, users_cnt) OVER (ORDER BY session_date)) - 1) * 100 AS user_growth
  FROM users_cnt;

-- вывести дату предыдщего заказ
SELECT order_id,
       user_id,
       paid_at,
       LAG(paid_at, 1, '1980-01-01') OVER (PARTITION BY user_id ORDER BY paid_at)
  FROM tools_shop.orders;

-- вывести дату следующего события
SELECT event_id,
       event_time,
       user_id,
       LEAD(event_time) OVER (PARTITION BY user_id ORDER BY event_time)
  FROM tools_shop.events;

-- аналогично, но с интервалом
SELECT event_id,
       event_time,
       user_id,
       LEAD(event_time) OVER (PARTITION BY user_id ORDER BY event_time) - event_time
  FROM tools_shop.events;