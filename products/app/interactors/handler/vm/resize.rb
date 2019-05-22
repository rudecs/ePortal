class Handler::VM::Resize < Handler::Base

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
        id: context.handler.machine_id,
        type: 'machine',
        state: 'active',
        vcpus: context.job.action_params['vcpus'],
        memory: context.job.action_params['memory'],
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
        context.fail! unless send_notification_about_product_instance_resized
      end
    end
  end

  def send_notification_about_product_instance_resized
    ::Notification::Template.send({
      key_name: Notification::Template::KEY_PRODUCT_RESIZED,
      client_ids: [context.product_instance.client_id],
      provided_data: {
        product_instance_id: context.product_instance.id,
        product_instance_name: context.product_instance.name,
        product_type_id: context.product_instance.product.id,
      },
    })
  end

end
