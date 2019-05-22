class Handler::VM::Stop < Handler::Base

  params do
    requires :product_instance, type: ::ProductInstance
    requires :handler, type: ::ProductInstance
    requires :job, type: ::ProductInstance
  end

  def call
    resp = ::Resources::Machine.new.stop(context.handler.machine_id)
    context.fail! unless context.product_instance.update_attributes({
      state: 'active',
    })
    context.fail! unless context.job.update_attributes({
      state: 'completed',
      error_messages: [],
    })
  end

  protected

end
