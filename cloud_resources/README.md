# Roadmap

## Resources Hierarchy

```plantuml

class CloudSpace
class Machine
class Port
class Disk
class Snapshot
class Image

CloudSpace --{ Machine
CloudSpace --{ Port
Machine --{ Port
Machine --{ Disk
Machine --{ Snapshot
```

---
## Общие поля для любого ресурса:
---

#### Если есть общая таблица для всех ресурсов:
* resource_id
* resource_type

#### Информация о владельце:
* partner_id
* client_id
* product_id
* product_instance_id

#### Как найти ресурс в облаке:
* location_id
* cloud_id
* cloud_name
* cloud_status

#### Служебное:
* current_event_id

---

### Проверка исполнения кода биллинга
```
be rspec spec/models/product_instance/handler_price_spec.rb
```
