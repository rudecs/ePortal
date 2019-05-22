class Notification::Template
  KEY_PRODUCT_CREATED = 'create_product'
  KEY_PRODUCT_RESIZED = 'resize_product'
  KEY_PRODUCT_TURNED_OFF = 'turn_off_product'
  KEY_PRODUCT_DELETED = 'delete_product'

  def self.send(key_name:, user_ids: nil, client_ids: nil, provided_data: {})
    if !user_ids.present? && !client_ids.present?
      return false
    end

    request_path = '/api/notifications/v1/notifications_requests.json'
    request_params = {
      notifications_request: {
        key_name: key_name,
        provided_data: provided_data,
      },
    }

    request_params[:notifications_request][:user_ids] = user_ids if user_ids.present?
    request_params[:notifications_request][:client_ids] = client_ids if client_ids.present?

    if Rails.env == 'development'
      puts '================================'
      puts 'Notification::Template#send'
      puts request_path
      puts JSON.pretty_generate(request_params)
      puts '================================'
      return
    end

    service = Diplomat::Service.get('notifications')
    url = "http://#{service.Address}:#{service.ServicePort}/"

    conn = Faraday.new(url: url) do |faraday|
      faraday.response :logger, ::Logger.new(STDOUT), bodies: true
      faraday.adapter  Faraday.default_adapter
      faraday.headers['Content-Type'] = 'application/json'
    end

    res = conn.post(request_path) do |req|
      req.body = request_params.to_json
    end
  end

end
