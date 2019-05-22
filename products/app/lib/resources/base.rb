class Resources::Base

  protected

  def faraday
    service = Diplomat::Service.get('resources')
    url = "http://#{service.Address}:#{service.ServicePort}/"

    Faraday.new(url: url) do |faraday|
      faraday.response :logger, ::Logger.new(STDOUT), bodies: true
      faraday.adapter  Faraday.default_adapter
      faraday.headers['Content-Type'] = 'application/json'
    end
  end
end
