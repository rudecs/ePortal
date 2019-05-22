class ProductInstance::VM::DeleteDisk < ProductInstance::Base

  params do
    optional :product_instance, type: ::ProductInstance
    optional :product_instance_id, type: Integer
    at_least_one_of :product_instance, :product_instance_id

    requires :id, type: Integer
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
      action_name: 'delete_disk',
      action_params: {
        id: context.id,
      }
    }
  end

end
