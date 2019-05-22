class GetUsageRecords
  include Interactor

  def call
    begin
      records = send_request_to_usage_service
    rescue => e
      context.fail! error: e
    end
    if !records.is_a? Array || records.empty?
      context.fail! error: 'Usage API did not return records'
    end

    context.records = records
  end

  protected

  def send_request_to_usage_service
    usage_params = { from: context.from, to: context.to, sort_key: sort_key_for_usage, hourly: true }
    response = Faraday.get usage_service_url, usage_params
    JSON.parse response.body
  end

  def sort_key_for_usage
    case context.resource_type
    when 'Charge::ProductInstance'
      'product_id' # default
    when 'Charge::CloudResource'
      'resource_id' # cloud_resource_id. Not use now. Maybe in future
    end
  end

  def usage_service_url
    if Rails.env.test?
      'http://localhost:8888/api/usage/v1/usages'
    else
      address = Diplomat::Service.get('usage').Address
      port = Diplomat::Service.get('usage').ServicePort
      "http://#{address}:#{port}/api/usage/v1/usages"
    end
    # 'http://185.193.143.91/api/usage/v1/usages'
  end
end
