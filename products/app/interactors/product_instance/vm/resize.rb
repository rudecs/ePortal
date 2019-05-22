class ProductInstance::VM::Resize < ProductInstance::Base

  params do
    optional :product_instance, type: ::ProductInstance
    optional :product_instance_id, type: Integer
    at_least_one_of :product_instance, :product_instance_id

    optional :vcpus, type: Integer
    optional :memory, type: Integer
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
      action_name: 'resize',
      action_params: {
        vcpus: context.vcpus,
        memory: context.memory,
      }
    }
  end

end
