class CloudAPI::Base
  STRUCT_FIELDS = []

  attr_reader :conn

  def initialize(location)
    # login = credentials['login']
    # password = credentials['password']
    # accountName = credentials['account_name']

    @struct = Struct.new(*self.class.const_get(:STRUCT_FIELDS))
    @location = location
    @cookie = "beaker.session.id=#{SecureRandom.hex}"

    @conn = Faraday.new(:url => @location.url) do |faraday|
      # faraday.request  :url_encoded             # form-encode POST params
      # faraday.response :logger                  # log requests to STDOUT
      faraday.response :logger, ::Logger.new(STDOUT), bodies: true
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      faraday.headers['Cookie'] = @cookie
      faraday.headers['Content-Type'] = 'application/json'
      faraday.options[:open_timeout] = 5 * 50
      faraday.options[:timeout] = 5 * 60
    end
  end

  def authenticate
    credentials = @location.credentials
    @conn.post('/system/login') do |req|
      req.body = {
        user_login_: credentials['login'],
        passwd: credentials['password'],
      }.to_json
    end

    res = @conn.post('/restmachine/cloudapi/accounts/list')
    res = self.parse_response(res)
    res = res.select {|ele| ele['name'] == credentials['account_name']}
    if res.size == 0
      raise "Account #{credentials['account_name']} not found"
    end
    @accountId = res[0]['id']
    @login = credentials['login']
    true
  end

  protected

  def parse_response(res)
    if [200,201].include? res.status
      return JSON.parse(res.body)
    end

    raise CloudAPI::Exceptions::Forbidden, res.body if res.status == 403
    raise CloudAPI::Exceptions::NotFound,  res.body if res.status == 404

    raise res.body
  end

  def create_struct(data)
    result = @struct.new
    self.class.const_get(:STRUCT_FIELDS).map do |field|
      result[field] = data[field.to_s]
    end
    result
  end
end
