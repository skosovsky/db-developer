-- вывести все поля и доп
SELECT *, SUM(total_amt) OVER (PARTITION BY user_id) AS user_sum, SUM(total_amt) OVER () AS sum_total
  FROM tools_shop.orders;

-- вывести все поля и количество
SELECT *, COUNT(*) OVER ()
  FROM tools_shop.users;

-- вывести все поля и сумму
SELECT *, SUM(total_amt) OVER (PARTITION BY DATE_TRUNC('month', created_at))
  FROM tools_shop.orders
 ORDER BY created_at;

-- средний чек по дням
SELECT *, AVG(revenue) OVER (PARTITION BY event_dt) AS avg_rev
  FROM online_store.orders;

-- с округлением
SELECT *, ROUND(AVG(revenue) OVER (PARTITION BY event_dt), 2) AS avg_rev
  FROM online_store.orders;

-- найти дату последнего заказ для каждого пользователя
SELECT *, MAX(event_dt) OVER (PARTITION BY user_id) AS last_order_dt
  FROM online_store.orders;

-- общее количество заказов по дням их оформления
SELECT *, COUNT(order_id) OVER (PARTITION BY created_at::DATE)
  FROM tools_shop.orders;

-- общую выручку по месяцам
SELECT *, SUM(total_amt) OVER (PARTITION BY DATE_TRUNC('MONTH', paid_at::DATE))
  FROM tools_shop.orders;