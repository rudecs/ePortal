class Handler::VDC::Stop < Handler::Base

  params do
    requires :product_instance, type: ::ProductInstance
    requires :handler, type: ::ProductInstance
    requires :job, type: ::ProductInstance
  end

  def call
    ActiveRecord::Base.transaction do
      context.fail! unless context.product_instance.update_attributes({
        state: 'active',
      })
      context.fail! unless context.job.update_attributes({
        state: 'completed',
        error_messages: [],
      })
    end
  end

  protected

end
