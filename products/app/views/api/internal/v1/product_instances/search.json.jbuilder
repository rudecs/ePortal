json.product_instances @product_instances do |product_instance|
  json.id             product_instance.id
  json.product_id     product_instance.product_id
  json.client_id      product_instance.client_id
  json.name           product_instance.name
  json.state          product_instance.state
  json.type           product_instance.product.type
  json.created_at     product_instance.created_at
  json.updated_at     product_instance.updated_at
  json.deleted_at     product_instance.deleted_at
  json.resources      product_instance.fetch_resources
  unless @no_handler_price
    json.handler_price  product_instance.handler_price
  end

  handler = product_instance.handler
  if handler.present?
    if handler.class == ::Handler::VDC
      json.location_id handler.location_id
    elsif handler.class == ::Handler::VM
      json.product_instance_vdc_id handler.product_instance_vdc_id
      json.location_id             handler.location_id
    end
  end
end
