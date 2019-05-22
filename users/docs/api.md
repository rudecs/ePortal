# Users

## API endpoints
### /api/users/v1/register
----
  Регистрация пользователя. В случае приглашения, в ссылке содержится query-параметры `invitation_token`, `email`, который можно передать в скрытом поле.
* **Method:**
  `POST`
*  **URL Params**
  None
* **Query Params** <br />
   **Required:** <br />
  ```
  user[email]=[string]
  user[password]=[string]
  ```
  <br />
   **Optional:** <br />
  ```
  invitation_token=[string]
  ```

<br />
TODO: пагинации на 'index' запросах
<br />

### /api/users/v1/clients
----
  Требует аутентификации!
  Список клиентов пользователя
* **Method:**
  `GET`
* **Query Params** <br />
   **Optional:** <br />
  ```
  page=[integer]
  per_page=[integer]
  ```

### /api/users/v1/clients/:client_id/users
----
  Требует аутентификации!
  Список пользователей клиента
* **Method:**
  `GET`
* **Query Params** <br />
   **Optional:** <br />
  ```
  page=[integer]
  per_page=[integer]
  ```

### /api/users/v1/clients/:client_id/roles
----
  Требует аутентификации!
  Список ролей, созданных в клиенте
* **Method:**
  `GET`



## Приглашения с точки зрения клиента
### /api/users/v1/clients/:client_id/invitations
----
  Требует аутентификации!
  Список исходящих приглашений(статус: на рассмотрении/pending) от клиента
* **Method:**
  `GET`
* **Query Params** <br />
   **Optional:** <br />
  ```
  page=[integer]
  per_page=[integer]
  ```

### /api/users/v1/clients/:client_id/invitations
----
  Требует аутентификации!
  Отправить приглашение. Переотправку добавлю скорее всего по этому же маршруту, пока не реализовано
* **Method:**
  `POST`
* **Query Params** <br />
   **Required:** <br />
  ```
  invitation[email]=[string]
  invitation[role_id]=[integer]
  ```

### /api/users/v1/clients/:client_id/invitations/:id
----
  Требует аутентификации!
  Отмена приглашения(удаление).
* **Method:**
  `DELETE`


## Приглашения с точки зрения пользователя
### /api/users/v1/invitations
----
  Требует аутентификации!
  Список приглашений текущего пользователя в статусе "на рассмотрении(pending)".
* **Method:**
  `GET`
* **Query Params** <br />
   **Required:** <br />
  none
  <br />
   **Optional:** <br />
  ```
  page=[integer]
  per_page=[integer]
  ```


### /api/users/v1/invitations/:id/accept
----
  Требует аутентификации!
  Принять приглашение.
* **Method:**
  `POST`


### /api/users/v1/invitations/:id/reject
----
  Требует аутентификации!
  Отклонить приглашение.
* **Method:**
  `POST`
