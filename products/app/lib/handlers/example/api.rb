class Handlers::Example::API
  attr_accessor :product_instance, :cloud_resources

  def initialize(product_instance)
    @cloud_resources = ::CloudResources.new
    @product_instance = product_instance
  end


  def create
    cloud_space_id = @cloud_resources.get_free_ids(1)[0]
    machine_id = @cloud_resources.get_free_ids(1)[0]

    cloud_space_playbook_schema_element = {
      id: cloud_space_id,
      type: 'cloud_space',
      state: 'active',
      location_id: @product_instance.action_params['location_id'],
      client_id: @product_instance.client_id,
      product_id: @product_instance.product_id,
      product_instance_id: @product_instance.id,
    }

    machine_playbook_schema_element = {
      id: machine_id,
      cloud_space_id: cloud_space_id,
      image_id: @product_instance.action_params['image_id'],
      client_id: @product_instance.client_id,
      product_id: @product_instance.product_id,
      product_instance_id: @product_instance.id,
      type: 'machine',
      state: 'active',
      vcpus: @product_instance.action_params['vcpus'],
      memory: @product_instance.action_params['memory'],
      boot_disk_size: @product_instance.action_params['boot_disk_size'],
    }

    playbook = @cloud_resources.create_playbook([
      cloud_space_playbook_schema_element,
      machine_playbook_schema_element,
    ])

    @product_instance.update_attributes({
      state: 'processing',
      playbook_id: playbook['id'],
    })
  end

  def delete
    cloud_space_id = self.cloud_space.id
    machine_id = self.machine.id

    cloud_space_playbook_schema_element = {
      id: cloud_space_id,
      type: 'cloud_space',
      state: 'deleted',
    }

    machine_playbook_schema_element = {
      id: machine_id,
      type: 'machine',
      state: 'deleted',
    }

    playbook = @cloud_resources.create_playbook([
      cloud_space_playbook_schema_element,
      machine_playbook_schema_element,
    ])

    @product_instance.update_attributes({
      state: 'processing',
      playbook_id: playbook['id'],
    })
  end

  def reload
    return unless @product_instance.playbook_id.present?
    playbook = @cloud_resources.get_playbook(@product_instance.playbook_id)
    playbook['schema'].map do |ele|
      resource = ::Resource.find_or_create_by({
        id: ele['id'],
        type: ele['type'],
        product_instance_id: @product_instance.id,
      })
    end

    if playbook['state'] == 'failed'
      @product_instance.update_attributes({
        state: 'failed',
        error_messages: playbook['error_messages'],
      })
    elsif playbook['state'] == 'deployed'
      if @product_instance.action_name == 'delete'
        @product_instance.update_attributes({
          state: 'deleted',
          error_messages: playbook['error_messages'],
          deleted_at: Time.now,
        })
      else
        @product_instance.update_attributes({
          state: 'active',
          error_messages: playbook['error_messages'],
        })
      end
    elsif %w(pending deploying).include? playbook['state']
      @product_instance.update_attributes({
        state: 'active',
        error_messages: [],
      }) if @product_instance.state != 'processing'
    end
  end

  def resize
    machine_id = self.machine.id

    machine_playbook_schema_element = {
      id: machine_id,
      type: 'machine',
      state: 'active',
      vcpus: @product_instance.action_params['vcpus'],
      memory: @product_instance.action_params['memory'],
      boot_disk_size: @product_instance.action_params['boot_disk_size'],
    }

    playbook = @cloud_resources.create_playbook([
      machine_playbook_schema_element,
    ])

    @product_instance.update_attributes({
      state: 'processing',
      playbook_id: playbook['id'],
    })
  end


  protected

  def cloud_space
    @product_instance.resources.find_by(type: 'cloud_space')
  end

  def machine
    @product_instance.resources.find_by(type: 'machine')
  end

end
