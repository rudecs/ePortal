class CloudAPI::Machine < CloudAPI::Base
  STRUCT_FIELDS = [
    :id, :imageid, :cloudspaceid,
    :name, :description, :hostname,
    :status,
    :memory, :vcpus, :storage, :sizeid,
    :creationTime, :updateTime,
    :osImage, :disks, :interfaces,
    :locked, :accounts
  ]

  def list(cloud_space_id)
    self.authenticate
    url = "/restmachine/cloudapi/machines/list"
    res = @conn.post(url) do |req|
      req.body = {
        cloudspaceId: cloud_space_id,
      }.to_json
    end
    self.parse_response(res).map do |data|
      self.create_struct(data)
    end
  end

  def find(id)
    self.authenticate
    url = "/restmachine/cloudapi/machines/get"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: id,
      }.to_json
    end
    res = self.parse_response(res)
    self.create_struct(res)
  end

  def create(cloudspaceId:, imageId:, name:, memory:, vcpus:, disksize:, ssh_keys: [])
    userdata = {
      users: [
        name: 'cloudscalers',
        'ssh-authorized-keys': ssh_keys,
        shell: '/bin/bash'
      ]
    }

    name = name.to_s
    name += "_#{SecureRandom.hex}" if Rails.env == 'development'
    self.authenticate
    url = "/restmachine/cloudapi/machines/create"
    res = @conn.post(url) do |req|
      req.body = {
        cloudspaceId: cloudspaceId,
        imageId: imageId,
        name: name,
        memory: memory,
        vcpus: vcpus,
        disksize: disksize,
        userdata: userdata,
      }.to_json
    end
    id = self.parse_response(res)
    self.find(id)
  end

  def update(id:, name:)
    self.authenticate
    url = "/restmachine/cloudapi/machines/update"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: id,
        name: name
      }.to_json
    end
    self.parse_response(res)
    self.find(id)
  end

  def resize(id:, memory:, vcpus:)
    self.authenticate
    url = "/restmachine/cloudapi/machines/resize"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: id,
        memory: memory,
        vcpus: vcpus,
      }.to_json
    end
    self.parse_response(res)
    self.find(id)
  end

  def delete(id)
    self.authenticate
    url = "/restmachine/cloudapi/machines/delete"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: id,
      }.to_json
    end
    self.parse_response(res)
  rescue CloudAPI::Exceptions::NotFound
    # TODO отправить нотификацию админам об ошибке
    return true
  end

  def start(id)
    self.authenticate
    url = "/restmachine/cloudapi/machines/start"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: id,
      }.to_json
    end
    self.parse_response(res)
  end

  def stop(id)
    self.authenticate
    url = "/restmachine/cloudapi/machines/stop"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: id,
      }.to_json
    end
    self.parse_response(res)
  end

  def pause(id)
    self.authenticate
    url = "/restmachine/cloudapi/machines/pause"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: id,
      }.to_json
    end
    self.parse_response(res)
  end

  def get_console_url(id)
    self.authenticate
    url = "/restmachine/cloudapi/machines/getConsoleUrl"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: id,
      }.to_json
    end
    self.parse_response(res)
  end

  def attach_disk(machine_id:, disk_id:)
    self.authenticate
    url = "/restmachine/cloudapi/machines/attachDisk"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: machine_id,
        diskId: disk_id,
      }.to_json
    end
    self.parse_response(res)
  end

  protected
end



# Example disks and interfaces response:
# "disks": [
#   {
#     "acl": {
#     },
#     "descr": "Machine disk of type B",
#     "id": 51,
#     "name": "Boot disk",
#     "sizeMax": 10,
#     "status": "",
#     "type": "B"
#   },
#   {
#     "acl": {
#     },
#     "descr": "",
#     "id": 52,
#     "name": "Metadata iso",
#     "sizeMax": 0,
#     "status": "",
#     "type": "M"
#   }
# ],
# "interfaces": [
#   {
#     "deviceName": "vm-22-0079",
#     "guid": "",
#     "ipAddress": "192.168.103.254",
#     "macAddress": "52:54:00:00:00:16",
#     "networkId": 0,
#     "params": "",
#     "referenceId": "",
#     "status": "",
#     "type": "bridge"
#   }
# ],
