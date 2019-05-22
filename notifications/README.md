# Notifications

Не конечный вариант. Кое-что явно нужно подправить.

```plantuml
class NotificationRequest {
  Запрос на уведомление
  --
  + id : integer
  --
  + key_name : string
  + locale : string
  + content : text
  + delivery_method : string
  + provided_data : jsonb
  --
  + client_ids : array[integer]
  + category : string
  + user_ids : array[integer]
  --
  + processed_at : datetime
  --
  + created_at : datetime
  + updated_at : datetime
}

class Notification {
  Уведомление
  --
  + id : integer
  + notifications_request_id : integer
  + user_id : integer
  + template_id : integer
  --
  + content : text
  + delivery_method : string
  + destination : string
  --
  + delivered_at : datetime
  + read_at : datetime
  --
  + created_at : datetime
  + updated_at : datetime
}

class Template {
  Шаблон
  --
  + id : integer
  + templates_set_id : integer
  --
  + content : string
  + locale : string
  + delivery_method : string
  + subject : string
  --
  + created_at : datetime
  + updated_at : datetime
}

class TemplatesSet {
  Набор шаблонов
  --
  + id : integer
  --
  + key_name : string
  + category : string
  --
  + created_at : datetime
  + updated_at : datetime
}

TemplatesSet --{ Template
NotificationRequest --{ Notification
Template --{ Notification
```

## API endpoints
### /api/notifications/v1/notifications_requests
----
  Заявка на создание и рассылку уведомлений
* **Method:**
  `POST`
* **Params** <br />
  ```
  requires :notifications_request, type: Hash do
    optional :content, type: String EX: '<p>Confirmation link</p>'
    optional :key_name, type: String EX: 'email_confirmation'
    mutually_exclusive :key_name, :content (Либо контент подставится из шаблона по ключу, либо если нет ключа(key_name), то нужно предоставить контент с произвольным текстом)
    optional :delivery_method, type: String (Нужно указать 'sms'/'email... ')
    all_or_none_of :content, :delivery_method (подставится из шаблона по ключу. Указать самому, если без key_name(шаблона))
    optional :user_ids, type: Array[Integer] (Отправить конкретному пользователю(ям))
    optional :client_ids, type: Array[Integer] (Отправить всем пользователям Клиента(ов))
    exactly_one_of :client_ids, :user_ids (Разрешено что-то одно или Пользователю/Клиенту)
    optional :category, type: String EX: Пока не реализовано до конца, но можно например отправить только бухгалтеру, указав категорию finance. Если есть шаблон, само будет подставляться
    mutually_exclusive :category, :user_ids
    optional :provided_data, type: Hash EX: {email: 'example@mail.ru'} Если в шаблоне(контенте) есть переменная email для парсинга '<p>Привет пользователь с почтой {{ email }}</p>'. Некоторые(типа почты) могут быть взяты автоматически в Клиентах, а некоторые необходимо указывать в этом поле типа {{super_custom_value: 'v'}}, их список тоже ограничен, нельзя передать все,что душе захочется
  end
  ```

### /api/notifications/v1/templates_sets
----
* **Method:**
  `POST`
* **Params** <br />
  ```
  requires :templates_set, type: Hash do
    requires :key_name, type: String
    optional :category, type: String
    optional :templates_attributes, type: Array do
      optional :_destroy, type: Boolean
      requires :content, type: String
      requires :locale, type: String
      requires :delivery_method, type: String
      optional :subject, type: String
    end
  end
  ```
