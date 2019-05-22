class Handlers::VM::API < Handlers::Base
  attr_accessor :product_instance, :cloud_resources

  def create
    if @product_instance_job.handler_fn_params['cloud_space_id'].present?
      return self.create_machine
    end

    # parse cloud space id
    if @product_instance_job.handler_fn_params['cloud_space_product_instance_id'].present?
      pi = ProductInstance.find(@product_instance_job.handler_fn_params['cloud_space_product_instance_id'])
      if pi.state == 'processing'
        return
      elsif pi.state == 'failed'
        ActiveRecord::Base.transaction do
          @product_instance.update_attributes({
            state: failed,
            error_messages: pi.error_messages,
          })
          @product_instance_job.update_attributes({
            state: failed,
            finished_at: Time.now,
          })
        end
      elsif pi.state == 'deleted'
        @product_instance_job.handler_fn_params['cloud_space_product_instance_id'] = nil
        @product_instance_job.save!
        return self.create
      elsif pi.state == 'active'
        cloud_space = pi.resources.find_by_type('cloud_space')
        @product_instance_job.handler_fn_params['cloud_space_id'] = cloud_space.id
        @product_instance_job.save!
        return self.create
      end
    end

    self.create_cloud_space
  end

  def resize
    # REVIEW: handle disks? or in resize_disk?
    machine_playbook_schema_element = {
      id: self.machine.id,
      type: 'machine',
      state: 'active',
      vcpus: @product_instance_job.handler_fn_params['vcpus'],
      memory: @product_instance_job.handler_fn_params['memory'],
      boot_disk_size: @product_instance_job.handler_fn_params['boot_disk_size'],
      iops_sec: @product_instance_job.handler_fn_params['iops_sec'],
    }

    playbook = @cloud_resources.create_playbook([
      machine_playbook_schema_element,
    ])

    @product_instance.update_attributes({
      state: 'processing',
      playbook_id: playbook['id'],
    })

    @product_instance_job.update_attributes({
      state: 'processing',
    })
  end

  def add_disk
    return false unless @product_instance_job.handler_fn_params['machine_id'] # REVIEW: ?
    disk_playbook_schema_element = {
      id: @cloud_resources.get_free_ids(1)[0],
      machine_id: @product_instance_job.handler_fn_params['machine_id'],
      client_id: @product_instance.client_id,
      product_id: @product_instance.product_id,
      product_instance_id: @product_instance.id,
      type: 'disk',
      state: 'active',
      size: @product_instance_job.handler_fn_params['size'],
      name: @product_instance_job.handler_fn_params['name'],
      disk_type: @product_instance_job.handler_fn_params['type'],
      iops_sec: @product_instance_job.handler_fn_params['iops_sec'],
    }

    playbook = @cloud_resources.create_playbook([
      disk_playbook_schema_element,
    ])

    @product_instance.update_attributes({
      state: 'processing',
      playbook_id: playbook['id'],
    })

    @product_instance_job.update_attributes({
      state: 'processing',
    })
  end

  def manage_disks
    return false unless @product_instance_job.handler_fn_params['machine_id'] # REVIEW: ?
    unless @product_instance_job.handler_fn_params['additional_disks'].present?
      @product_instance_job.update_attributes({
        state: 'completed',
      })
      @product_instance.update_attributes({
        state: 'active',
      }) if @product_instance.state == 'processing'
      return
    end

    disk_playbook_schema_elements = @product_instance_job.handler_fn_params['additional_disks'].map do |disk_params|
      {
        id: disk_params['id'] || @cloud_resources.get_free_ids(1)[0],
        machine_id: @product_instance_job.handler_fn_params['machine_id'],
        client_id: @product_instance.client_id,
        product_id: @product_instance.product_id,
        product_instance_id: @product_instance.id,
        type: 'disk',
        state: disk_params['state'] || 'active',
        size: disk_params['size'],
        name: disk_params['name'],
        disk_type: disk_params['type'],
        iops_sec: disk_params['iops_sec'],
      }
    end

    playbook = @cloud_resources.create_playbook(disk_playbook_schema_elements)

    @product_instance.update_attributes({
      state: 'processing',
      playbook_id: playbook['id'],
    })

    @product_instance_job.update_attributes({
      state: 'processing',
    })
  end

  def delete_disk
    # REVIEW: handler_fn_params['id']
    return false unless @product_instance_job.handler_fn_params['id']
    disk_playbook_schema_element = {
      id: self.disk(@product_instance_job.handler_fn_params['id']).id,
      type: 'disk',
      state: 'deleted',
    }

    playbook = @cloud_resources.create_playbook([
      disk_playbook_schema_element,
    ])

    @product_instance.update_attributes({
      state: 'processing',
      playbook_id: playbook['id'],
    })

    @product_instance_job.update_attributes({
      state: 'processing',
    })
  end

  def resize_disk
    # REVIEW: handler_fn_params['id']
    return false unless @product_instance_job.handler_fn_params['id']
    disk_playbook_schema_element = {
      id: self.disk(@product_instance_job.handler_fn_params['id']).id,
      type: 'disk',
      state: 'active',
      size: @product_instance_job.handler_fn_params['size'],
      iops_sec: @product_instance_job.handler_fn_params['iops_sec'],
    }

    playbook = @cloud_resources.create_playbook([
      disk_playbook_schema_element,
    ])

    @product_instance.update_attributes({
      state: 'processing',
      playbook_id: playbook['id'],
    })

    @product_instance_job.update_attributes({
      state: 'processing',
    })
  end

  def disable
    # resources should handle availability to change state?
    playbook_schema_element = {
      id: self.machine.id,
      type: 'machine',
      status: 'HALTED'
    }

    playbook = @cloud_resources.create_playbook([
      machine_playbook_schema_element,
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
    # make it API call?
    playbook_schema_element = {
      id: self.machine.id,
      type: 'machine',
      status: 'RUNNING' # TODO: pass previous status? prepare resources for status change!
    }

    playbook = @cloud_resources.create_playbook([
      machine_playbook_schema_element,
    ])

    @product_instance.update_attributes({
      state: 'processing',
      playbook_id: playbook['id'],
    })

    @product_instance_job.update_attributes({
      state: 'processing',
    })
  end

  def create_snapshot
    return false unless @product_instance_job.handler_fn_params['machine_id'] # REVIEW: ?
    snapshot_playbook_schema_element = {
      id: @cloud_resources.get_free_ids(1)[0],
      machine_id: @product_instance_job.handler_fn_params['machine_id'],
      client_id: @product_instance.client_id,
      product_id: @product_instance.product_id,
      product_instance_id: @product_instance.id,
      name: @product_instance_job.handler_fn_params['name'],
      type: 'snapshot',
      state: 'active',
    }

    playbook = @cloud_resources.create_playbook([
      snapshot_playbook_schema_element,
    ])

    @product_instance.update_attributes({
      state: 'processing',
      playbook_id: playbook['id'],
    })

    @product_instance_job.update_attributes({
      state: 'processing',
    })
  end

  def delete_snapshot
    return false unless @product_instance_job.handler_fn_params['snapshot_id'] # REVIEW: ?
    snapshot_playbook_schema_element = {
      id: @product_instance_job.handler_fn_params['snapshot_id'],
      type: 'snapshot',
      state: 'deleted',
    }

    playbook = @cloud_resources.create_playbook([
      snapshot_playbook_schema_element,
    ])

    @product_instance.update_attributes({
      state: 'processing',
      playbook_id: playbook['id'],
    })

    @product_instance_job.update_attributes({
      state: 'processing',
    })
  end

  protected

  def create_machine
    machine_id = @cloud_resources.get_free_ids(1)[0]

    machine_playbook_schema_element = {
      id: machine_id,
      cloud_space_id: @product_instance_job.handler_fn_params['cloud_space_id'],
      image_id: @product_instance_job.handler_fn_params['image_id'],
      client_id: @product_instance.client_id,
      product_id: @product_instance.product_id,
      product_instance_id: @product_instance.id,
      type: 'machine',
      state: 'active',
      vcpus: @product_instance_job.handler_fn_params['vcpus'],
      memory: @product_instance_job.handler_fn_params['memory'],
      boot_disk_size: @product_instance_job.handler_fn_params['boot_disk_size'],
    }

    schemas = [machine_playbook_schema_element]

    additional_disks = @product_instance_job.handler_fn_params['additional_disks']
    if additional_disks.present?
      disk_ids = @cloud_resources.get_free_ids(additional_disks.length)
      additional_disks.each_with_index do |disk, index|
        schemas << {
          id: disk_ids[index],
          machine_id: machine_id,
          client_id: @product_instance.client_id,
          product_id: @product_instance.product_id,
          product_instance_id: @product_instance.id,
          type: 'disk',
          state: 'active',
          name: disk['name'],
          size: disk['size'],
          disk_type: disk['type'],
          iops_sec: disk['iops_sec'],
        }
      end
    end

    playbook = @cloud_resources.create_playbook(schemas)

    @product_instance.update_attributes({
      state: 'creating',
      playbook_id: playbook['id'],
    })

    @product_instance_job.update_attributes({
      state: 'processing',
    })
  end

  def create_cloud_space
    ActiveRecord::Base.transaction do
      cloud_space_product = Product.find_by(type: 'vdc')
      cloud_space_product_instance = ProductInstance.create!({
        name: @product_instance_job.handler_fn_params['cloud_space_name'],
        product_id: cloud_space_product.id,
        client_id: @product_instance.client_id,
        state: 'creating',
        handler_price: cloud_space_product.handler_price,
      })

      @product_instance_job.handler_fn_params['cloud_space_product_instance_id'] = cloud_space_product_instance.id
      @product_instance_job.save!

      cloud_space_product_instance_job = ProductInstanceJob.create!({
        state: 'new',
        product_instance_id: cloud_space_product_instance.id,
        handler_fn_name: 'create',
        handler_fn_params: {
          "location_id" => @product_instance_job.handler_fn_params['location_id'],
        },
      })

      ProductInstanceJobRelation.create!({
        job_id: @product_instance_job.id,
        before_job_id: cloud_space_product_instance_job.id,
      })
    end
  end

  def machine
    @product_instance.resources.find_by(type: 'machine')
  end

  def disk(id)
    @product_instance.resources.where(type: 'disk').find(id)
  end

end
