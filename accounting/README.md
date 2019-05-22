# ACCOUNTING

* TODO: прием платежей.

* Configuration.
  Microservice uses 2 dbs: accounting and clients.
  Clients is external db with at least read rigths.

* Database creation.
  Create accounting databases as usual. TODO: clients db.

* Database initialization.
  Initialize Clients db in `/config/initializers/clients_database.rb`

* Services (job queues, cache servers, search engines, etc.)

```plantuml
class Client {
  Клиент
  --
  + id : integer
  + name : string
  + state : string
  --
  + current_balance_cents : integer
  + currency : string
  + discount_package_id : integer
  --
  + writeoff_type : string
  + writeoff_date : datetime
  + writeoff_interval : integer
  --
  + deleted_at : datetime
  --
  + created_at : datetime
  + updated_at : datetime
}

class Writeoff {
  Списание
  --
  + id : integer
  + client_id : integer
  --
  + state : string
  --
  + amount : decimal
  + initial_amount : decimal
  + currency : string
  --
  + start_date : datetime
  + end_date : datetime
  + paid_at : datetime
  --
  + created_at : datetime
  + updated_at : datetime
}

class ProductInstanceState {
  Состояние облачного ресурса
  --
  + id : integer
  + writeoff_id : integer
  --
  + product_id : integer
  + product_instance_id : integer
  + billing_data : jsonb
  --
  + start_at : datetime
  + end_at : datetime
  --
  + created_at : datetime
  + updated_at : datetime
}

class PaymentTransaction {
  Транзакция
  --
  + id : integer
  + client_id : integer
  + subject_id : integer
  + subject_type : string
  --
  + amount : decimal
  + currency : string
  --
  + created_at : datetime
  + updated_at : datetime
}

class Payment {
  Платеж(поступление)
}

class Discount {
  Скидка
  --
  + id : integer
  --
  + key_name : string (cpu/memory...)
  --
  + created_at : datetime
  + updated_at : datetime
}

class DiscountPackage {
  Набор скидок
  --
  + id : integer
  --
  + name : string
  + description : text
  --
  + created_at : datetime
  + updated_at : datetime
}

class DiscountSet {
  Соединительная модель для скидок и наборов
  --
  + id : integer
  + discount_id : integer
  + discount_package_id : integer
  --
  + amount : decimal
  + amount_type : string
  --
  + created_at : datetime
  + updated_at : datetime
}

Client --{ Writeoff
Client --{ Payment
Client --{ PaymentTransaction
Payment -- PaymentTransaction : > subject_of
Writeoff -- PaymentTransaction : > subject_of
Writeoff --{ ProductInstanceState
DiscountPackage --{ Client
DiscountPackage --{ DiscountSet
Discount --{ DiscountSet
```

## API endpoints
### /api/accounting/v1/writeoffs
----
  Требует аутентификации!
  Возвращает аггрегированные по месяцам списания для конкретного клиента.
  Каждое такое списание содержит в себе `writeoff_month` год и месяц аггрегированнго списания.
  `writeoff_month` используется ля запроса более подробной информации по аггрегированному списанию.
* **Method:**
  `GET`
*  **URL Params**
  None
* **Query Params** <br />
   **Required:** <br />
  ```
  client_id=[integer]
  ```
  <br />
   **Optional:** <br />
  ```
  page=[integer]
  per_page=[integer]
  ```
* **Success Response:**
  * **Code:** Completed 200 OK <br />
    **Content example:**
    ```
    {
      "writeoffs": [
        {
          "amount_sum": "720.0001",
          "initial_amount_sum": "720.0001",
          "writeoff_month": "2018-05-01"
        },
        {
          "amount_sum": "720.0001",
          "initial_amount_sum": "720.0001",
          "writeoff_month": "2018-04-01"
        },
        {
          "amount_sum": "720.0001",
          "initial_amount_sum": "720.0001",
          "writeoff_month": "2018-03-01"
        }
      ],
      "total_count": 3
    }
    ```


### api/accounting/v1/writeoffs/show
----
  Требует аутентификации!
  Возваращает списания, дата окончания которых попадает в период `writeoff_month`, для конкретного клиента.
  `date = writeoff_month` содержится в аггрегированном списании из `/api/accounting/v1/writeoffs` запроса.
* **Method:**
  `GET`
*  **URL Params**
  None
* **Query Params** <br />
   **Required:** <br />
  ```
  client_id=[integer]
  date=[date]
  ```
  <br />
   **Optional:** <br />
  ```
  page=[integer]
  per_page=[integer]
  ```
* **Success Response:**
  * **Code:** Completed 200 OK <br />
    **Content example without Optional parameters:**
    ```
    {
      "writeoffs": [
        {
          "id": 8,
          "amount": "720.0001",
          "initial_amount": "720.0001",
          "start_date": "2018-05-31T16:00:00.000Z",
          "end_date": "2018-05-31T16:59:59.999Z",
          "billing": [
            {
              "product_instance_id": 333,
              "states": [
                {
                  "id": 22,
                  "product_id": 222,
                  "product_instance_id": 333,
                  "billing_data": {
                    "cpu": {
                      "count": 10,
                      "price": 200,
                      "currency": "rub"
                    },
                    "memory": {
                      "count": 2000,
                      "price": 120,
                      "currency": "rub"
                    }
                  },
                  "start_at": "2018-06-13T04:00:00.000Z",
                  "end_at": "2018-06-13T05:59:59.000Z"
                },
                {
                  "id": 23,
                  "product_id": 222,
                  "product_instance_id": 333,
                  "billing_data": {
                    "cpu": {
                      "count": 10,
                      "price": 100,
                      "currency": "rub"
                    },
                    "memory": {
                      "count": 4000,
                      "price": 100.00019,
                      "currency": "rub"
                    }
                  },
                  "start_at": "2018-06-13T06:00:00.000Z",
                  "end_at": "2018-06-13T06:59:59.000Z"
                }
              ]
            },
            {
              "product_instance_id": 444,
              "states": [
                {
                  "id": 24,
                  "product_id": 333,
                  "product_instance_id": 444,
                  "billing_data": {
                    "cpu": {
                      "count": 10,
                      "price": 100,
                      "currency": "rub"
                    },
                    "memory": {
                      "count": 4000,
                      "price": 100,
                      "currency": "rub"
                    }
                  },
                  "start_at": "2018-06-13T06:00:00.000Z",
                  "end_at": "2018-06-13T06:59:59.000Z"
                }
              ]
            }
          ]
        },
        {
          "id": 7,
          "amount": "720.0001",
          "initial_amount": "720.0001",
          "start_date": "2018-05-31T15:00:00.000Z",
          "end_date": "2018-05-31T15:59:59.999Z",
          "billing": [
            {
              "product_instance_id": 333,
              "states": [
                {
                  "id": 19,
                  "product_id": 222,
                  "product_instance_id": 333,
                  "billing_data": {
                    "cpu": {
                      "count": 10,
                      "price": 200,
                      "currency": "rub"
                    },
                    "memory": {
                      "count": 2000,
                      "price": 120,
                      "currency": "rub"
                    }
                  },
                  "start_at": "2018-06-13T04:00:00.000Z",
                  "end_at": "2018-06-13T05:59:59.000Z"
                },
                {
                  "id": 20,
                  "product_id": 222,
                  "product_instance_id": 333,
                  "billing_data": {
                    "cpu": {
                      "count": 10,
                      "price": 100,
                      "currency": "rub"
                    },
                    "memory": {
                      "count": 4000,
                      "price": 100.00019,
                      "currency": "rub"
                    }
                  },
                  "start_at": "2018-06-13T06:00:00.000Z",
                  "end_at": "2018-06-13T06:59:59.000Z"
                }
              ]
            },
            {
              "product_instance_id": 444,
              "states": [
                {
                  "id": 21,
                  "product_id": 333,
                  "product_instance_id": 444,
                  "billing_data": {
                    "cpu": {
                      "count": 10,
                      "price": 100,
                      "currency": "rub"
                    },
                    "memory": {
                      "count": 4000,
                      "price": 100,
                      "currency": "rub"
                    }
                  },
                  "start_at": "2018-06-13T06:00:00.000Z",
                  "end_at": "2018-06-13T06:59:59.000Z"
                }
              ]
            }
          ]
        }
      ],
      "total_count": 5
    }
    ```
