class ServiceHttpClient
  def self.create(service_name)
    service = Diplomat::Service.get(service_name)
    url = "http://#{service.Address}:#{service.ServicePort}/"

    conn = Faraday.new(:url => url) do |faraday|
      # faraday.request  :url_encoded             # form-encode POST params
      # faraday.response :logger                  # log requests to STDOUT
      faraday.response :logger, ::Logger.new(STDOUT), bodies: true
      # faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      faraday.adapter :typhoeus
      faraday.headers['Content-Type'] = 'application/json'
    end

    conn
  end
end
