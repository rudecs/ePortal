# Usage

## Deployment
* setup cron task(cron:hourly_reports). Должно выполняться в начале каждого часа, но не ровно в ХХ.00.00.000

```plantuml
class Resource {
  Облачный ресурс
  --
  + id
  + resource_id
  + product_id
  + product_instance_id
  + client_id
  + partner_id
  --
  + kind
  --
  + deleted_at
  + originally_created_at
  + created_at
  + updated_at
}

class Event {
  Событие об изменении ресурса
  --
  + id
  + resource_id
  --
  + name : integer
  Enum: create, resize, delete
  --
  + type : string
  --
  + resource_parameters : jsonb
  --
  + started_at
  + finished_at
  + created_at
  + updated_at
}

class MachineEvent {
  resource_parameters: {}
  + memory : integer
  + vcpus : integer
  + boot_disk_size : integer
}

class CloudSpaceEvent {
  resource_parameters: {}
}

class Payload {
  Утилизация, usage
  --
  + id
  + resource_id
  --
  + chargable : jsonb
  --
  + period_start
  + period_end
  + created_at
  + updated_at
}

Resource --{ Event
Event <|-- MachineEvent
Event <|-- CloudSpaceEvent
Resource --{ Payload
```

## API endpoints
### /api/usage/v1/resources
----
  Handles incoming resources with events
* **Method:**
  `POST`
*  **URL Params**
  None
* **Data Params** <br />
  ```
  resource_id=[integer] (uniq Resource id)
  resource=[string] (machine/cloud_space)
  product_id=[integer]
  product_instance_id=[integer]
  client_id=[integer]
  partner_id=[integer]
  event_started_at=[integer]
  event_finish_at=[integer]
  event=[string] (create/resize/delete)
  memory=[integer]
  vcpus=[integer]
  boot_disk_size=[integer]
  ```
* **Success Response:**
  * **Code:** Completed 200 OK
* **Error Response:**
  * **Code:** Completed 422 Unprocessable Entity


<br />
### /api/usage/v1/usages
----
  Потребление за период времени (от, до).
  По умолчанию происходит группировка по `product_instance_id`.
  Также добавляется группировка по параметрам из `Query Params Arrays`, если таковые присутствуют.
  После группировки ресурсы разделяются по типам(machine/cloud_space).
* **Method:**
  `GET`
*  **URL Params**
  None
* **Query Params** <br />
   **Required:** <br />
  ```
  from=[datetime]
  to=[datetime]
  ```
  <br />
   **Optional:** <br />
  `hourly=[boolean]` <br />
  Arrays:
  ```
  product_ids[]=[integer]
  product_instance_ids[]=[integer]
  client_ids[]=[integer]
  partner_ids[]=[integer]
  ```
  <br />
  Если нужна дополнительная группировка по какому-нибудь полю:
  `sort_key=[string]`, valid values: `[resource_id product_id client_id partner_id]`
* **Success Response:**
  * **Code:** Completed 200 OK <br />
    **Content example without Optional parameters:**
    ```
    [
      {
        "cloud_spaces": {
          "resources_count": 1
        },
        "machines": {
          "resources_count": 1,
          "vcpus": 1,
          "memory": 1,
          "boot_disk_size": 1
        },
        "start_at": "2018-04-24 08:00:00 +0300",
        "end_at": "2018-04-28 09:59:59 +0300",
        "client_id": 1,
        "product_instance_id": 1
      },
      {
        "cloud_spaces": {
          "resources_count": 1
        },
        "start_at": "2018-04-24 08:00:00 +0300",
        "end_at": "2018-04-28 09:59:59 +0300",
        "client_id": 7,
        "product_instance_id": 7
      },
      {
        "machines": {
          "resources_count": 1,
          "vcpus": 2,
          "memory": 2,
          "boot_disk_size": 2
        },
        "start_at": "2018-04-24 08:00:00 +0300",
        "end_at": "2018-04-28 09:59:59 +0300",
        "client_id": 7,
        "product_instance_id": 8
      }
    ]
    ```
* **Error Response:**
  * **Code:** Completed 400 Bad Request


<br />
### /api/usage/v1/usages/speed
----
  Скорость потребления ресурсов в момент времени.
  По умолчанию происходит группировка по `product_instance_id`.
  Также добавляется группировка по параметрам из `Query Params Arrays`, если таковые присутствуют.
  После группировки ресурсы разделяются по типам(machine/cloud_space).
* **Method:**
  `GET`
*  **URL Params**
  None
* **Query Params** <br />
   **Required:** <br />
  `speed_at=[datetime]`
  <br />
   **Optional:** <br />
  Arrays:
  ```
  product_ids[]=[integer]
  product_instance_ids[]=[integer]
  client_ids[]=[integer]
  partner_ids[]=[integer]
  ```
  <br />
  Если нужна дополнительная группировка по какому-нибудь полю:
  `sort_key=[string]`, valid values: `[resource_id product_id client_id partner_id]`
* **Success Response:**
  * **Code:** Completed 200 OK <br />
    **Content example without Optional parameters:**
    ```
    [
      {
        "cloud_spaces": {
          "resources_count": 1
        },
        "client_id": 1,
        "product_instance_id": 1
      },
      {
        "cloud_spaces": {
          "resources_count": 1
        },
        "client_id": 7,
        "product_instance_id": 7
      },
      {
        "machines": {
          "resources_count": 1,
          "vcpus": 1,
          "memory": 1,
          "boot_disk_size": 1
        },
        "client_id": 8,
        "product_instance_id": 9
      }
    ]
    ```
* **Error Response:**
  * **Code:** Completed 400 Bad Request
