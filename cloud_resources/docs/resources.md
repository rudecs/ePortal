# Models

```plantuml
class Location {
  + id
  --
  + code
  + url
  + state
  [active, disabled]
  --
  + sizes
  [{memory, vcpus, disks}]
  --
  + created_at
  + updated_at
  + deleted_at
}

object size {
  JSON поле в таблице locations
  ----
  + memory int
  Размер оперативной памяти, мегабайт
  + vcpus int
  Количество ядер, единиц
  + disks [int]
  Массив доступных размеров
  загрузочных дисков, гигабайт
}

class Image {
  Образы виртуальных машин
  --
  + id
  + cloud_id
  + location_id
  --
  + name
  + description
  --
  + state
  + platform
  Linux, Windows
  --
  + created_at
  + updated_at
  + deleted_at
}

class CloudSpace {
  Объединение виртуальных машин:
  локальная сеть, внешний ip адрес
  --
  + id
  + cloud_id
  + location_id
  --
  + product_id
  + client_id
  + partner_id
  --
  + state
  + public_ip
  --
  + created_at
  + updated_at
  + deleted_at
}

class Machine {
  + id
  + cloud_id
  + cloud_space_id
  + image_id
  --
  + product_id
  + client_id
  + partner_id
  --
  + memory
  + vcpus
  + boot_disk_size
  --
  + state
  /* + status {on off} */
  --
  + created_at
  + updated_at
  + deleted_at
}

class Port {
  + id
  + cloud_id
  + cloud_space_id
  + machine_id
  --
  + protocol
  tcp, udp
  + public_ip
  + public_port
  --
  + created_at
  + updated_at
  + deleted_at
}

class Disk {
  + id
  + cloud_id
  --
  + size
  + ssd_size
  + iops
  defaults to 2000
  + type
  B=Boot;D=Data;T=Temp
}

class Playbook {
  + id
  --
  + state
  pending, processing, completed, failed
  + errors
  Сообщения об ошибке, если state == failed
  --
  + schema
  --
  + rollback()
  Метод для удаления всех уже созданных ресурсов.
  + restart()
  Пересоздает ресурсы.
}

Location --{ CloudSpace
Location -{ size
Location --{ Image
CloudSpace --{ Machine
CloudSpace --{ Port
Machine }-{ Port

Image --{ Machine

class machine_version {
  + id
  + machine_id
  --
  + memory
  + vcpus
  + state
  --
  + created_at
}

Machine --{ machine_version

```

* cloud_id - специальное поле, обозначает id сущности, которое отдает API JumpScale.


# States

*Устарело, смотри секцию "States [updated]" ниже.*

```plantuml
(pending) -> (validation)
(validation) -> (validation_failed)
(validation) --> (deploying)
(deploying) -> (deploying_failed)
(deploying) --> (deployed)
(deployed) --> (deleting)
(deleting) -> (deleting_failed)
(deleting) --> (deleted)

(deployed) .> (pending)
(validation_failed) .> (pending)
(deploying_failed) .> (pending)
```

* pending - ресурс в очереди на исполнение, стартовый статус при создании экземпляра ресурса
* validation - валидация ресурса
* validation_failed - ресурс не прошел валидацию
* deploying - исполнение ресурса (создание, изменение)
* deploying_failed - ошибка на этапе исполнения
* deployed - ресурс активен
* deleting - ресурс удаляется
* deleting_error - ошибка на этапе удаления ресурса
* deleted - ресурс удален
* ~~archived - ресурс архивирован (нужно уточнить, как работает эта фича, все ли внутренние ресурсы ее поддерживают), пока не ясно, нужен ли этот статус~~


## States [updated]


```plantuml
(processing) --> (active)
(processing) --> (deleted)
(processing) -->(failed)
(active) --> (processing)
(failed) --> (processing)
```


```plantuml
class AbstractResource {
  + id
  + partner_id
  + current_action_id [only for processing state]
  --
  + state
  processing, active, failed, deleted
  --
  + created_at
  + updated_at
  + deleted_at
}

class Action {
  + id
  + resource_id
  + resource_type
  --
  + name
  deploy, delete, resize [for machine], etc
  + params
  json field
  + errors
  array of objects, or empty array, or nil
  + finished
  true/false
  --
  + created_at
  + updated_at
}

AbstractResource -- Action
AbstractResource --{ Action
```
