
- регистрация и подтверждение емайла:
```plantuml
User -> Server: register
Server -> User: send email_confirmation_code
User -> Server: confirm email
```

- ввод номера телефона и подтверждение:
```plantuml
@startuml
User -> Server: authenticate
User -> Server: save/update phone number
Server -> User: send phone_confirmation_code
User -> Server: confirm phone
@enduml
```

- изменение существующего номера телефона и подтверждение:
```plantuml
@startuml
User -> Server: authenticate
User -> Server: update phone number
Server -> User: send phone_confirmation_code
User -> Server: confirm new phone
@enduml
```


- юзер не получил смс с подтверждением, запрос нового кода:
```plantuml
@startuml
User -> Server: authenticate
Server -> User: request to generate another phone_confirmation_code
Server -> User: send phone_confirmation_code
User -> Server: confirm phone
@enduml
```
