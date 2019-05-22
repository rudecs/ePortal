class ProductInstance::VM::ManageDisks < ProductInstance::Base

  params do
    optional :product_instance, type: ::ProductInstance
    optional :product_instance_id, type: Integer
    at_least_one_of :product_instance, :product_instance_id

    requires :additional_disks, type: Array[Hash] do
      optional :name, type: String
      requires :size, type: Integer
      requires :type, type: String
      optional :iops_sec, type: Integer
    end
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
      action_name: 'manage_disks',
      action_params: {
        additional_disks: context.additional_disks,
      }
    }
  end

end
