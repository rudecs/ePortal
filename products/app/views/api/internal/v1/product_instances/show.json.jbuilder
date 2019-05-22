json.product_instance do
  json.id             @product_instance.id
  json.product_id     @product_instance.product_id
  json.client_id      @product_instance.client_id
  json.name           @product_instance.name
  json.state          @product_instance.state
  json.type           @product_instance.product.type
  json.handler_price  @product_instance.handler_price
  json.created_at     @product_instance.created_at
  json.updated_at     @product_instance.updated_at
  json.deleted_at     @product_instance.deleted_at
  json.resources      @product_instance.fetch_resources

  handler = @product_instance.handler
  if handler.present?
    if handler.class == ::Handler::VDC
      json.location_id handler.location_id
    elsif handler.class == ::Handler::VM
      json.product_instance_vdc_id handler.product_instance_vdc_id
      json.location_id             handler.location_id
    end
  end

  json.jobs @product_instance.jobs do |job|
    json.id             job.id
    json.state          job.state
    json.action_name    job.action_name
    json.action_params  job.action_params
    json.error_messages job.error_messages
    json.created_at     job.created_at
    json.finished_at    job.finished_at
  end
end
