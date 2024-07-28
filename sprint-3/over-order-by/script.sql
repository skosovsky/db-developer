-- сумма затрат с накопилением
SELECT *, SUM(costs) OVER (ORDER BY dt) AS costs_sum
  FROM online_store.costs
 WHERE channel = 'Yandex';

-- раздельные подсчеты
SELECT user_id, session_duration, session_start, SUM(session_duration) OVER (PARTITION BY user_id ORDER BY session_start)
  FROM online_store.sessions;

-- вариант с COUNT
SELECT user_id, COUNT(*) OVER (PARTITION BY dt ORDER BY user_id)
  FROM online_store.profiles;

-- минимальные
SELECT *, MIN(costs) OVER (ORDER BY dt) AS costs_sum
  FROM online_store.costs
 WHERE channel = 'Yandex';

-- сумму с накоплением
SELECT paid_at, total_amt, SUM(total_amt) OVER (ORDER BY paid_at)
  FROM tools_shop.orders;

-- сумму с накоплением по пользователям
SELECT user_id, paid_at, total_amt, SUM(total_amt) OVER (PARTITION BY user_id ORDER BY paid_at)
  FROM tools_shop.orders;

-- сумму с накоплением по месячно
SELECT DATE_TRUNC('MONTH', paid_at)::DATE,
       total_amt,
       SUM(total_amt) OVER (ORDER BY DATE_TRUNC('MONTH', paid_at)::DATE)
  FROM tools_shop.orders;

-- сумма трат на привлечение
SELECT DISTINCT DATE_TRUNC('MONTH', created_at)::DATE, SUM(costs) OVER (ORDER BY DATE_TRUNC('MONTH', created_at)::DATE)
  FROM tools_shop.costs
 WHERE created_at BETWEEN '2017-01-01' AND '2018-12-31'
 ORDER BY 1;