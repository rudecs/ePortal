class JumpScale
  def initialize(location, login, password)
    @location = location
    @login = login
    @password = password
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
    @conn.post('/system/login') do |req|
      req.body = {
        user_login_: @login,
        passwd: @password
      }.to_json
    end

    res = @conn.post('/restmachine/cloudapi/accounts/list')
    res = self.parse_response(res)
    @accountId = res[0]['id']
  end

  def cloudspaces_create(name)
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
    self.parse_response(res)
  end

  def cloudspaces_delete(id)
    self.authenticate
    url = "/restmachine/cloudapi/cloudspaces/delete"
    res = @conn.post(url) do |req|
      req.body = {
        cloudspaceId: id,
      }.to_json
    end
    self.parse_response(res)
  end

  def cloudspaces_get(id)
    self.authenticate
    url = "/restmachine/cloudapi/cloudspaces/get"
    res = @conn.post(url) do |req|
      req.body = {
        cloudspaceId: id,
      }.to_json
    end
    self.parse_response(res)
  end

  def cloudspaces_list
    self.authenticate
    url = "/restmachine/cloudapi/cloudspaces/list"
    res = @conn.post(url)
    self.parse_response(res)
  end

  def images_list
    self.authenticate
    url = "/restmachine/cloudapi/images/list"
    res = @conn.post(url)
    self.parse_response(res)
  end

  def machines_create(cloud_space_id:, name:, size_id:, image_id:, boot_disk_size:)
    self.authenticate
    url = "/restmachine/cloudapi/machines/create"
    res = @conn.post(url) do |req|
      req.body = {
        cloudspaceId: cloud_space_id,
        name: name,
        sizeId: size_id,
        imageId: image_id,
        disksize: boot_disk_size
      }.to_json
    end
    self.parse_response(res)
  end

  def machines_delete(machine_id)
    self.authenticate
    url = "/restmachine/cloudapi/machines/delete"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: machine_id,
      }.to_json
    end
    self.parse_response(res)
  end

  def machines_get(machine_id)
    self.authenticate
    url = "/restmachine/cloudapi/machines/get"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: machine_id,
      }.to_json
    end
    self.parse_response(res)
  end

  def machines_resize(machine_id, size_id)
    self.authenticate
    url = "/restmachine/cloudapi/machines/resize"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: machine_id,
        sizeId: size_id,
      }.to_json
    end
    self.parse_response(res)
  end

  def machines_start(machine_id)
    self.authenticate
    url = "/restmachine/cloudapi/machines/start"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: machine_id,
      }.to_json
    end
    self.parse_response(res)
  end

  def machines_stop(machine_id)
    self.authenticate
    url = "/restmachine/cloudapi/machines/stop"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: machine_id,
      }.to_json
    end
    self.parse_response(res)
  end

  def machines_pause(machine_id)
    self.authenticate
    url = "/restmachine/cloudapi/machines/pause"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: machine_id,
      }.to_json
    end
    self.parse_response(res)
  end

  def machines_get_console_url(machine_id)
    self.authenticate
    url = "/restmachine/cloudapi/machines/getConsoleUrl"
    res = @conn.post(url) do |req|
      req.body = {
        machineId: machine_id,
      }.to_json
    end
    self.parse_response(res)
  end

  def sizes_list
    self.authenticate
    url = "/restmachine/cloudapi/sizes/list"
    res = @conn.post(url) do |req|
      req.body = {
        location: @location.code,
      }.to_json
    end
    self.parse_response(res)
  end

  protected

  def parse_response(res)
    if res.status != 200
      raise "#{res.status} #{res.body}"
    end

    JSON.parse(res.body)
  end
end
