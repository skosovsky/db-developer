-- несколько OVER
SELECT *,
       ROW_NUMBER() OVER (ORDER BY revenue),
       RANK() OVER (ORDER BY revenue),
       DENSE_RANK() OVER (ORDER BY revenue)
  FROM online_store.orders;

-- аналогично
SELECT *,
       ROW_NUMBER() OVER my_window,
       RANK() OVER my_window,
       DENSE_RANK() OVER my_window
  FROM online_store.orders
WINDOW my_window AS (ORDER BY revenue);

-- проранжировать расходы по убыванию
SELECT created_at::DATE,
       costs,
       ROW_NUMBER() OVER (ORDER BY costs DESC)
  FROM tools_shop.costs;

-- аналогично, но с одинаковым рангом
SELECT created_at::DATE,
       costs,
       DENSE_RANK() OVER (ORDER BY costs DESC)
  FROM tools_shop.costs;

-- количество заказа в котором 4
SELECT COUNT(order_id)
  FROM (SELECT order_id, ROW_NUMBER() OVER (PARTITION BY order_id) AS order_rang
          FROM tools_shop.order_x_item) AS orders_with_rangs
 WHERE order_rang >= 4;

-- количество пользователей по месяцам
SELECT DISTINCT DATE_TRUNC('MONTH', created_at)::DATE,
                COUNT(user_id) OVER (ORDER BY DATE_TRUNC('MONTH', created_at)::DATE)
  FROM tools_shop.users;

-- сумарная стоимость заказов
SELECT order_id,
       DATE_TRUNC('MONTH', paid_at)::DATE,
       total_amt,
       COUNT(order_id) OVER window_month,
       SUM(total_amt) OVER window_month
  FROM tools_shop.orders
WINDOW window_month AS (ORDER BY DATE_TRUNC('MONTH', paid_at)::DATE);

-- сумма трат по месяцам, разницу между текущим и прошлыми месяцами
SELECT month, month_cost, month_cost - LAG(month_cost, 1, month_cost) OVER (ORDER BY month)
  FROM (SELECT DATE_TRUNC('MONTH', created_at)::DATE AS month, SUM(costs) AS month_cost
          FROM tools_shop.costs
         GROUP BY month) AS months_costs;

-- сумму разницу по годам и разницу
SELECT year, year_revenue, LEAD(year_revenue, 1, year_revenue) OVER (ORDER BY year) - year_revenue
  FROM (SELECT DATE_TRUNC('YEAR', paid_at)::DATE AS year, SUM(total_amt) AS year_revenue
          FROM tools_shop.orders
         GROUP BY year) AS years_revenues;