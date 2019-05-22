class Handler::VM::CreateSnapshot < Handler::Base

  params do
    requires :product_instance, type: ::ProductInstance
    requires :handler, type: ::ProductInstance
    requires :job, type: ::ProductInstance
  end

  def call
    create_playbook
    process_playbook
  end

  protected

  def create_playbook
    return if context.job.playbook_id.present?
    playbook = context.handler.cloud_resources.create_playbook([
      {
        client_id: context.product_instance.client_id,
        product_id: context.product_instance.product_id,
        product_instance_id: context.product_instance.id,
        machine_id: context.handler.machine_id,
        type: 'snapshot',
        state: 'active',
        name: context.job.action_params['name'],
      }
    ])

    unless context.job.update_attributes(playbook_id: playbook['id'])
      context.fail!
    end

    unless context.product_instance.update_attributes(state: 'processing')
      context.fail!
    end
  end

  def process_playbook
    playbook = context.handler.cloud_resources.get_playbook(context.job.playbook_id)
    ActiveRecord::Base.transaction do
      if playbook['state'] == 'failed'
        context.fail! unless context.product_instance.update_attributes(state: 'active')
        context.fail! unless context.job.update_attributes({
          state: 'failed',
          error_messages: playbook['error_messages'],
        })
      elsif playbook['state'] == 'deployed'
        context.fail! unless context.product_instance.update_attributes({
          state: 'active',
        })
        context.fail! unless context.job.update_attributes({
          state: 'completed',
          error_messages: [],
        })
      end
    end
  end

end
