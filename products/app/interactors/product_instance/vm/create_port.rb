class ProductInstance::VM::CreatePort < ProductInstance::Base

  params do
    optional :product_instance, type: ::ProductInstance
    optional :product_instance_id, type: Integer
    at_least_one_of :product_instance, :product_instance_id

    requires :cloud_protocol, type: String
    requires :cloud_local_port, type: Integer
    requires :cloud_public_port, type: Integer
  end

  def call
    super

    ready_for_new_job?
    create_job

    context.product_instance.update_attributes(state: 'processing')
  end

  protected

  def create_job_params
    {
      product_instance_id: context.product_instance.id,
      state: 'new',
      action_name: 'create_port',
      action_params: {
        cloud_protocol: context.cloud_protocol,
        cloud_local_port: context.cloud_local_port,
        cloud_public_port: context.cloud_public_port,
      }
    }
  end

end
