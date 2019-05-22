class ProductInstance::VDC::Delete < ProductInstance::Base

  params do
    optional :product_instance, type: ::ProductInstance
    optional :product_instance_id, type: Integer
    at_least_one_of :product_instance, :product_instance_id
  end

  def call
    super

    ready_for_new_job?
    create_job

    context.product_instance.update_attributes(state: 'processing')
  end

  protected

  def create_job
    context.job = ::ProductInstanceJob.new(create_job_params)
    unless context.job.save
      errors = context.job.errors.messages.map {|k,v| [k,v]}
      context.errors[:job] = errors
      context.fail!
    end
  end

  def create_job_params
    {
      product_instance_id: context.product_instance.id,
      state: 'new',
      action_name: 'delete',
      action_params: {
        previous_product_instance_state: context.product_instance.state,
      },
    }
  end

end
