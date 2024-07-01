-- найдем ошибочные данные
SELECT *
  FROM purchases
           JOIN clients ON purchases.client_id = clients.id
 WHERE ((clients.name = 'Роберт' AND clients.surname = 'Земекис')
     OR (clients.name = 'Антон' AND clients.surname = 'Иванов'))
   AND purchases.billing_city = 'Париж';

-- удалим эти ошибочные данные
   DELETE
     FROM purchases
         USING clients
    WHERE purchases.client_id = clients.id
      AND ((clients.name = 'Роберт' AND clients.surname = 'Земекис')
        OR (clients.name = 'Антон' AND clients.surname = 'Иванов'))
      AND purchases.billing_city = 'Париж'
RETURNING purchases.*;

-- найдем еще одну ошибку
SELECT purchases.*
  FROM purchases,
       clients,
       products
 WHERE clients.id = purchases.client_id
   AND purchases.product_id = products.id
   AND products.type = 'Аудиотрек'
   AND clients.phone IN ('654-42-18', '321-55-91');

-- удалим эти строки
   DELETE
     FROM purchases
         USING clients, products
    WHERE clients.id = purchases.client_id
      AND purchases.product_id = products.id
      AND products.type = 'Аудиотрек'
      AND clients.phone IN ('654-42-18', '321-55-91')
RETURNING purchases.*;