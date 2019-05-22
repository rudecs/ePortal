class Handlers::VDC::API < Handlers::Base
  def create
    cloud_space_id = @cloud_resources.get_free_ids(1)[0]

    cloud_space_playbook_schema_element = {
      id: cloud_space_id,
      type: 'cloud_space',
      state: 'active',
      location_id: @product_instance_job.handler_fn_params['location_id'],
      client_id: @product_instance.client_id,
      product_id: @product_instance.product_id,
      product_instance_id: @product_instance.id,
      name: @product_instance.name,
    }

    playbook = @cloud_resources.create_playbook([
      cloud_space_playbook_schema_element,
    ])

    @product_instance.update_attributes({
      state: 'processing',
      playbook_id: playbook['id'],
    })

    @product_instance_job.update_attributes({
      state: 'processing',
    })
  end

  def enable
    @product_instance.soft_restore!
  end

  def disable
    @product_instance.soft_disable!
  end

  protected

  def cloud_space
    @product_instance.resources.find_by(type: 'cloud_space')
  end

end
