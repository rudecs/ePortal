class CloudAPI::Image < CloudAPI::Base
  STRUCT_FIELDS = [
    :id, :name, :description, :status, :type, :size,
    :accountId, :username
  ]

  def list
    self.authenticate
    url = "/restmachine/cloudapi/images/list"
    res = @conn.post(url) do |req|
      req.body = { accountId: @accountId.to_i }.to_json
    end
    self.parse_response(res).map do |data|
      next unless data['accountId'] == @accountId # REVIEW
      self.create_struct(data)
    end.compact
  end

  protected
end
