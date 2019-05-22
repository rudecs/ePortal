# PAY

* Configuration.
  Microservice uses 2 dbs: pay and clients.
  Clients is external db with read rigths.

* Database creation.
  Create database as usual. TODO: clients db.

* Database initialization.
  Initialize Clients db in `/config/initializers/clients_database.rb`

* Services (job queues, cache servers, search engines, etc.)

```plantuml
class Payment {
  Платеж
  --
  + id : integer
  + client_id : integer
  + user_id : integer
  --
  + amount_cents : integer
  + currency : string
  --
  + paid_at : datetime
  + charged_at : datetime
  --
  + status : string
  + payment_method : string
  --
  + created_at : datetime
  + updated_at : datetime
}

class Client {
  Клиент
  --
  + id : integer
  + name : string
  --
  + currency : string
  --
  + created_at : datetime
  + updated_at : datetime
}

class User {
  Пользователь
  --
  + id : integer
  --
  + email : string
  + phone : string
  + first_name : string
  + last_name : string
  --
  + created_at : datetime
  + updated_at : datetime
}

Client --{ Payment
User --{ Payment
```

## API endpoints
### /api/pay/v1/payments
----
  Требует аутентификации!
  Возвращает созданный платеж с дополнительной информацией для отправки формы на внешний платежный шлюз.
* **Method:**
  `POST`
* **Post Params** <br />
   **Required:** <br />
  ```
  client_id: integer
  payment: { amount_cents: integer }
  ```
* **Success Response:**
  * **Code:** Completed 200 OK <br />
    **Content example:**
    ```
      {
        "payment": {
          "id": 1,
          "formatted_amount": "100.00",
          "currency": "RUB",
          "signature": "ff281bbd0556608bfd9f00631bb37734"
        },
        "details": {
          "merchant": "demo2",
          "url": "https://secure.payu.ru/order/lu.php",
          "product": "Пополнение баланса",
          "order_date": "2018-06-19 13:45:36",
          "order_qty": ["1"],
          "order_vat": ["0"]
        },
        "user": {
          "id": 1,
          "email": "qqq@qqq.qqq",
          "phone": nil,
          "first_name": "fake_first_name",
          "last_name": "fake_last_name"
        },
        "client": {
          "id": 5,
          "name": "fake_name"
        }
      }
    ```


## PayU ipn route
### /api/pay/ipn
----
  Получение данных от платежного шлюза PayU. Внимание! Есть ограничения для использования этого маршрута.
* **Constraints:**
  `app/lib/constraints/payu.rb` <br />
  ip adresses: `['176.223.167.70', '185.68.12.69']`
* **Method:**
  `GET`, `POST`
* **Success Response:**
  * **Code:** Completed 200 OK <br />
    **Content example:**
    GET: `true` <br />
    POST: `<epayment>20180620104334|ad9fcdfbc9124c858c36e86901bc51bd</epayment>`
