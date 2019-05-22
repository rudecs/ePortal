class CloudAPI::Disk < CloudAPI::Base
  STRUCT_FIELDS = [
    :id, :gid, :guid, :stackId,
    :name, :type, :status,
    :sizeMax, :sizeUsed,
    :iotune,
  ]

  def list(type=nil)
    self.authenticate
    url = "/restmachine/cloudapi/disks/list"
    res = @conn.post(url) do |req|
      req.body = {
        accountId: @accountId,
        type: type,
      }.to_json
    end
    self.parse_response(res).map do |data|
      self.create_struct(data)
    end
  end

  def find(id)
    self.authenticate
    url = "/restmachine/cloudapi/disks/get"
    res = @conn.post(url) do |req|
      req.body = {
        diskId: id,
      }.to_json
    end
    res = self.parse_response(res)
    self.create_struct(res)
  end

  def create(name:, size:, type:, iops:, description: nil)
    name = name.to_s
    name += "_#{SecureRandom.hex}" if Rails.env == 'development'
    description = name if description.nil?
    self.authenticate
    url = "/restmachine/cloudapi/disks/create"
    res = @conn.post(url) do |req|
      req.body = {
        accountId: @accountId,
        gid: @location.gid,
        name: name,
        description: description,
        size: size,
        type: type,
        iops: iops,
      }.to_json
    end
    id = self.parse_response(res)
    self.find(id)
  end

  def limit_io(id:, iops_sec:, bytes_sec:)
    self.authenticate
    url = "/restmachine/cloudapi/disks/limitIO"
    res = @conn.post(url) do |req|
      req.body = {
        diskId: id,
        total_iops_sec: iops_sec,
        total_bytes_sec: bytes_sec,
      }.to_json
    end
    self.parse_response(res)
    # self.find(id)
  end

  def delete(id, detach=true)
    self.authenticate
    url = "/restmachine/cloudapi/disks/delete"
    res = @conn.post(url) do |req|
      req.body = {
        diskId: id,
        detach: detach,
      }.to_json
    end
    self.parse_response(res)
    # self.find(id)
  end

  def resize(id, size)
    self.authenticate
    url = "/restmachine/cloudapi/disks/resize"
    res = @conn.post(url) do |req|
      req.body = {
        diskId: id,
        size: size,
      }.to_json
    end
    self.parse_response(res)
    # self.find(id)
  end

  protected
end
