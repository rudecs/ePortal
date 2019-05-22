class CloudAPI::Location < CloudAPI::Base
  STRUCT_FIELDS = [
    :id, :gid, :guid, :flag, :locationCode, :name
  ]

  def list
    self.authenticate
    url = "/restmachine/cloudapi/locations/list"
    res = @conn.post(url)
    self.parse_response(res).map do |data|
      self.create_struct(data)
    end
  end

  def find(code)
    self.list.map do |location_struct|
      return location_struct if code == location_struct.locationCode
    end
    nil
  end

  protected

end
