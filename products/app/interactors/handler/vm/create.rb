class Handler::VM::Create < Handler::Base

  params do
    requires :product_instance, type: ::ProductInstance
    requires :handler, type: ::ProductInstance
    requires :job, type: ::ProductInstance
  end

  def call
    if context.handler.product_instance_vdc_id.nil?
      create_vdc
      return
    end

    vdc = ::ProductInstance.find(context.handler.product_instance_vdc_id)
    return if vdc.state == 'creating'
    return if vdc.state == 'processing'
    if vdc.state == 'failed'
      context.product_instance.update_attributes(state: 'failed')
      context.job.update_attributes({
        state: 'failed',
        error_messages: 'parent product instance failed',
      })
      context.fail!
    end
    if vdc.state == 'deleted'
      context.product_instance.update_attributes(state: 'failed')
      context.job.update_attributes({
        state: 'failed',
        error_messages: 'parent product instance deleted',
      })
      context.fail!
    end


    set_location_id(vdc)
    create_machine_id
    create_playbook
    process_playbook
  end

  protected

  def create_machine_id
    return if context.handler.machine_id.present?
    machine_id = context.handler.cloud_resources.get_free_ids(1)[0]
    unless context.handler.update_attributes(machine_id: machine_id)
      context.fail!
    end
  end

  def create_vdc
    vdc_context = ::ProductInstance::VDC::Create.call(create_vdc_params)
    context.fail! if vdc_context.failed?
    unless context.handler.update_attributes({
      product_instance_vdc_id: vdc_context.product_instance.id,
      location_id: vdc_context.handler.location_id,
    })
      context.fail!
    end
  end

  def create_vdc_params
    {
      name: context.job.action_params['product_instance_vdc_name'],
      description: context.job.action_params['product_instance_vdc_description'],
      client_id: context.job.action_params['product_instance_vdc_client_id'],
      product_id: context.job.action_params['product_instance_vdc_product_id'],
      location_id: context.job.action_params['product_instance_vdc_location_id'],
    }
  end


  def create_playbook
    return if context.job.playbook_id.present?
    schemas = []

    machine = {
      id: context.handler.machine_id,
      cloud_space_id: context.handler.product_instance_vdc.handler.cloud_space_id,
      type: 'machine',
      state: 'active',
      client_id: context.product_instance.client_id,
      product_id: context.product_instance.product_id,
      product_instance_id: context.product_instance.id,
      image_id: context.job.action_params['image_id'],
      vcpus: context.job.action_params['vcpus'],
      memory: context.job.action_params['memory'],
      boot_disk_size: context.job.action_params['boot_disk_size'],
      ssh_keys: context.job.action_params['ssh_keys'],
    }
    schemas << machine

    additional_disks = context.job.action_params['additional_disks']
    if additional_disks.present?
      disk_ids = context.handler.cloud_resources.get_free_ids(additional_disks.length)
      additional_disks.each_with_index do |disk, index|
        schemas << {
          id: disk_ids[index],
          machine_id: context.handler.machine_id,
          client_id: context.product_instance.client_id,
          product_id: context.product_instance.product_id,
          product_instance_id: context.product_instance.id,
          type: 'disk',
          state: 'active',
          name: disk['name'],
          size: disk['size'],
          disk_type: disk['disk_type'],
          iops_sec: disk['iops_sec'],
        }
      end
    end

    playbook = context.handler.cloud_resources.create_playbook(schemas)

    unless context.job.update_attributes(playbook_id: playbook['id'])
      context.fail!
    end
  end

  def process_playbook
    playbook = context.handler.cloud_resources.get_playbook(context.job.playbook_id)
    ActiveRecord::Base.transaction do
      if playbook['state'] == 'failed'
        context.fail! unless context.product_instance.update_attributes(state: 'failed')
        context.fail! unless context.job.update_attributes({
          state: 'failed',
          error_messages: playbook['error_messages'],
        })
      elsif playbook['state'] == 'deployed'
        context.fail! unless context.product_instance.update_attributes(state: 'active')
        context.fail! unless context.job.update_attributes({
          state: 'completed',
          error_messages: [],
        })
        context.fail! unless send_notification_about_product_instance_created
      end
    end
  end

  def set_location_id(vdc, vdc_handler=nil)
    return if context.handler.location_id.present?
    vdc_handler = vdc.handler if vdc_handler.nil?
    unless context.handler.update_attributes({
      location_id: vdc_handler.location_id,
    })
      context.fail!
    end
  end

end
