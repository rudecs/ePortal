
### API

Управление облачными ресурсами должно быть декларативного вида, ближайший аналог - ansible playbook. В общем виде взаимодействие между продуктом и ресурсами выглядит так:
1. Продукт отправляет json, содержащий схему готовой инфраструктуры, что-то вроде такого:
```js
[
  {
    location_id: 1,
    type: 'cloud_space',
    name: 'My VDC',
    machines: [
      {
        image_id: 12,
        type: 'machine',
        name: 'drupal',
        memory: 1024,
        vcpus: 1,
        disk_boot_size: 10,
      },
    ],
  },
  {
    type: 's3',
    name: 'my_bucket',
  },
]
```

2. В ответ ему придет что-то вроде:
```js
{
  id: 123,
  state: 'processing',
  content: "содержимое json'а, который он отправил в запросе"
}
```

3. Время от времени продукт будет спрашивать актуальную информацию о запросе ID 123. Если ```state: 'completed'``` - ресурсы готовы, если ```state: 'failed'``` - произошла ошибка.

Изменяя содержимое json'а, продукт управляет ресурсами - создает, изменяет, удаляет.

```plantuml

class product_resources_schema

class location {
  + id
}

class cloud_space {
  + id
  --
  + name
  + description
  --
  + state
}

class machine {
  + id
  --
  + name
  + description
  --
  + memory
  + vcpus
  + boot_disk_size
  ---
  + state
}

class bacula {
  + id
  --
  + ...params
  --
  + state
}

class s3 {
  + id
  + name
}

product_resources_schema --{ location
product_resources_schema --{ s3
location --{ cloud_space
cloud_space --{ machine
machine -{ bacula
```

---

```plantuml
class Schema {
  + id
  --
  + content:json
  --
  + state
  --
  + created_at
  + updated_at
  --
  + diff()
  Возвращает разницу между текущим и нужным
  состояниями ресурсов.
  + sync()
  Изменить ресурсы таким образом,
  чтобы они соответствовали схеме.
}

class SchemaCloudSpace {
  + id
  + location_id
  --
  + name
  + description
  --
  + state
  --
  + sync()
}

class SchemaMachine {
  + id
  + cloud_space_id
  --
  + name
  + description
  --
  + memory
  + vcpus
  + boot_disk_size
  --
  + state
  --
  + sync()
}

Schema --{ SchemaCloudSpace
SchemaCloudSpace  --{ SchemaMachine

```

#### States

```plantuml
(processing) --> (completed)
(processing) --> (failed)
```

---

```plantuml

node CloudResources
node Products
node Usage
node Billing

CloudResources -> Usage
Products -> CloudResources
Products -> Usage
```




```ruby
class CustomProduct
  attr_reader :executor_id

  def initialize
  end
end
```
