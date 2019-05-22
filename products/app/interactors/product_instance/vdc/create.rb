class ProductInstance::VDC::Create < ProductInstance::Base

  params do
    optional :product_instance, type: ::ProductInstance
    optional :product_instance_id, type: Integer
    at_least_one_of :product_instance, :product_instance_id

    optional :product, type: ::Product
    optional :product_id, type: Integer
    at_least_one_of :product, :product_id

    requires :client_id, type: Integer

    optional :name, type: String
    optional :description, type: String
  end

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
    if context.product.type != 'vdc'
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
    context.handler = ::Handler::VDC.new(create_handler_params)
    unless context.handler.save
      errors = context.handler.errors.messages.map {|k,v| [k,v]}
      context.errors[:handler] = errors
      context.fail!
    end
  end

  def create_handler_params
    {
      product_instance_id: context.product_instance.id,
      location_id: context.location_id,
    }
  end

  def create_job_params
    {
      product_instance_id: context.product_instance.id,
      state: 'new',
      action_name: 'create',
    }
  end

end
