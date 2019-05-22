class CloudAPI::Snapshot < CloudAPI::Base
  STRUCT_FIELDS = [
    :guid, :diskguid, :name, :epoch
  ]

  def list(machine_id=nil)
    self.authenticate
    url = "/restmachine/cloudapi/machines/listSnapshots"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: machine_id,
      }.to_json
    end
    self.parse_response(res).map do |data|
      self.create_struct(data)
    end
  end

  def create(machine_id:, name:)
    name = name.to_s
    name += "_#{SecureRandom.hex}" if Rails.env == 'development'
    self.authenticate
    url = "/restmachine/cloudapi/machines/snapshot"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: machine_id,
        name: name,
      }.to_json
    end
    self.parse_response(res)
    self.find(machine_id, name)
  end

  def find(machine_id, name)
    name = name.to_s
    self.list(machine_id).map do |snapshot|
      if name == snapshot.name
        return snapshot
      end
    end
  end

  def delete(machine_id, name)
    self.authenticate
    url = "/restmachine/cloudapi/machines/deleteSnapshot"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: machine_id,
        name: name,
      }.to_json
    end
    self.parse_response(res)
    return true
  end

  def rollback(machine_id, name, epoch)
    self.authenticate
    url = "/restmachine/cloudapi/machines/rollbackSnapshot"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: machine_id,
        name: name,
        epoch: epoch,
      }.to_json
    end
    self.parse_response(res)
    return true
  end

  protected
end
