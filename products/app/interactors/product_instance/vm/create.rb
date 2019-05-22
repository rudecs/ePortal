class ProductInstance::VM::Create < ProductInstance::Base

  params do
    optional :product_instance, type: ::ProductInstance
    optional :product_instance_id, type: Integer
    at_least_one_of :product_instance, :product_instance_id

    optional :product, type: ::Product
    optional :product_id, type: Integer
    at_least_one_of :product, :product_id

    requires :client_id, type: Integer

    optional :product_instance_vdc_id, type: Integer
    optional :product_instance_vdc_product_id, type: Integer
    optional :product_instance_vdc_location_id, type: Integer
    optional :product_instance_vdc_name, type: String
    optional :product_instance_vdc_description, type: String
    # requires one of: product_instance_vdc_id or product_instance_vdc_%(product_id, location_id. name, description)

    optional :name, type: String
    optional :description, type: String

    requires :image_id, type: Integer
    requires :vcpus, type: Integer
    requires :memory, type: Integer
    requires :boot_disk_size, type: Integer
    optional :additional_disks, type: Array[Hash] do
      optional :name, type: String
      requires :size, type: Integer
      requires :type, type: String
      optional :iops_sec, type: Integer
    end
    optional :ssh_keys, type: Array[String]
  end


  # context:
  def call
    super

    check_product_type

    ActiveRecord::Base.transaction do
      create_product_instance
      create_handler
      create_job
    end
  end

  protected

  def check_product_type
    if context.product.type != 'vm'
      context.errors[:product] = {
        type: ['is not included in the list']
      }
      context.fail!
    end
  end

  def create_product_instance
    context.product_instance = ::ProductInstance.new(create_product_instance_params)
    unless context.product_instance.save
      errors = context.product_instance.errors.messages.map {|k,v| [k,v]}
      context.errors[:product_instance] = errors
      context.fail!
    end
  end

  def create_product_instance_params
    {
      state: 'creating',
      client_id: context.client_id,
      product_id: context.product_id,
      name: context.name,
      description: context.description,
      handler_price: context.product.handler_price,
    }
  end

  def create_handler
    context.handler = ::Handler::VM.new(create_handler_params)
    unless context.handler.save
      errors = context.handler.errors.messages.map {|k,v| [k,v]}
      context.errors[:handler] = errors
      context.fail!
    end
  end

  def create_handler_params
    {
      product_instance_id: context.product_instance.id,
      product_instance_vdc_id: context.product_instance_vdc_id,
    }
  end

  def create_job_params
    {
      product_instance_id: context.product_instance.id,
      state: 'new',
      action_name: 'create',
      action_params: {
        image_id: context.image_id,
        vcpus: context.vcpus,
        memory: context.memory,
        boot_disk_size: context.boot_disk_size,
        additional_disks: context.additional_disks,
        ssh_keys: context.ssh_keys,
        product_instance_vdc_client_id: context.client_id,
        product_instance_vdc_product_id: context.product_instance_vdc_product_id,
        product_instance_vdc_location_id: context.product_instance_vdc_location_id,
        product_instance_vdc_name: context.product_instance_vdc_name,
        product_instance_vdc_description: context.product_instance_vdc_description,
      }
    }
  end
end
