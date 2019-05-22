class Resources::Machine < Resources::Base
  ATTRIBUTES = %w(
    id location_id partner_id client_id product_id product_instance_id
    cloud_id cloud_name cloud_status cloud_public_ip_address
    name description state
    created_at updated_at deleted_at
    type
  )

  attr_reader *ATTRIBUTES

  def find(id)
    url = "/api/resources/v1/machines/#{id}.json"
    res = faraday.get(url)
    res = JSON.parse(res.body)

    if res['code'] == 404
      raise Resources::Exceptions::NotFound
    end


    res = res['machine']
    # puts JSON.pretty_generate(res)

    res.each do |k, v|
      instance_variable_set("@#{k}", v)
    end
  end

  def stop(id)
    url = "/api/resources/v1/machines/#{id}/stop.json"
    res = faraday.post(url)
    res = JSON.parse(res.body)

    if res['code'] == 404
      raise Resources::Exceptions::NotFound
    end

    res
  end

end
