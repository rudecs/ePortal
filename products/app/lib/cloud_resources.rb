class CloudResources
  def initialize
    service = Diplomat::Service.get('resources')
    url = "http://#{service.Address}:#{service.ServicePort}/"

    @conn = Faraday.new(:url => url) do |faraday|
      # faraday.request  :url_encoded             # form-encode POST params
      # faraday.response :logger                  # log requests to STDOUT
      faraday.response :logger, ::Logger.new(STDOUT), bodies: true
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      faraday.headers['Content-Type'] = 'application/json'
    end
  end

  def get_free_ids(count=1)
    url = '/api/internal/v1/playbooks/free_ids.json'
    res = @conn.post(url) do |req|
      req.body = {
        count: count,
      }.to_json
    end
    self.parse_response(res)['ids']
  end

  def create_playbook(schema)
    url = '/api/internal/v1/playbooks.json'
    res = @conn.post(url) do |req|
      req.body = {
        playbook: {
          schema: schema,
        },
      }.to_json
    end
    self.parse_response(res)['playbook']
  end

  def get_playbook(playbook_id)
    url = "/api/internal/v1/playbooks/#{playbook_id}.json"
    res = @conn.get(url)
    self.parse_response(res)['playbook']
  end

  def get_resource(resource_id)
  end

  protected

  def parse_response(res)
    if res.status != 200 && res.status != 201
      raise "#{res.status} #{res.body}"
    end

    JSON.parse(res.body)
  end
end
