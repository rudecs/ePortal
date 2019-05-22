class ProductInstance::Base < BaseInteractor

  def call
    prepare_context
  end

  protected

  def prepare_context
    if context.product_id.present?
      context.product = ::Product.find(context.product_id)
    end

    if context.product_instance_id.present?
      context.product_instance = ::ProductInstance.find(context.product_instance_id)
    end

    context.errors = {}
  end

  def ready_for_new_job?
    if context.product_instance.jobs.where(state: %w(new processing)).present?
      context.errors[:base] = 'can not change processing product instance'
      context.fail!
    end
  end

  def create_job
    context.job = ::ProductInstanceJob.new(create_job_params)
    unless context.job.save
      errors = context.job.errors.messages.map {|k,v| [k,v]}
      context.errors[:job] = errors
      context.fail!
    end
  end

end
