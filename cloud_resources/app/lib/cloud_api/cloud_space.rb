class CloudAPI::CloudSpace < CloudAPI::Base
  STRUCT_FIELDS = [
    :location, :id, :name, :description, :status,
    :publicipaddress, :externalnetworkip,
    :creationTime, :updateTime,
    :gid, :secret
  ]

  def list
    self.authenticate
    url = "/restmachine/cloudapi/cloudspaces/list"
    res = @conn.post(url)
    self.parse_response(res).map do |data|
      self.create_struct(data)
    end
  end

  def find(id)
    self.authenticate
    url = "/restmachine/cloudapi/cloudspaces/get"
    res = @conn.post(url) do |req|
      req.body = {
        cloudspaceId: id,
      }.to_json
    end
    res = self.parse_response(res)
    self.create_struct(res)
  end

  def create(name)
    name = name.to_s
    name += "_#{SecureRandom.hex}" if Rails.env == 'development'
    self.authenticate
    url = "/restmachine/cloudapi/cloudspaces/create"
    res = @conn.post(url) do |req|
      req.body = {
        access: @login,
        accountId: @accountId,
        location: @location.code,
        name: name
      }.to_json
    end
    id = self.parse_response(res)
    self.find(id)
  end

  def update(id:, name:)
    self.authenticate
    url = "/restmachine/cloudapi/cloudspaces/update"
    res = @conn.post(url) do |req|
      req.body = {
        cloudspaceId: id,
        name: name
      }.to_json
    end
    self.parse_response(res)
    self.find(id)
  end

  def delete(id)
    self.authenticate
    url = "/restmachine/cloudapi/cloudspaces/delete"
    res = @conn.post(url) do |req|
      req.body = {
        cloudspaceId: id,
      }.to_json
    end
    self.parse_response(res)
  rescue CloudAPI::Exceptions::NotFound
    # TODO отправить нотификацию админам об ошибке
    return true
  end

  def deployVFW(id)
    self.authenticate
    url = "/cloudbroker/cloudspace/deployVFW"
    res = @conn.post(url) do |req|
      req.body = {
        cloudspaceId: id,
      }.to_json
    end
    self.parse_response(res)
  end

  protected
end
