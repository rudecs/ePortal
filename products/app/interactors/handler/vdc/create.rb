class Handler::VDC::Create < Handler::Base

  params do
    requires :product_instance, type: ::ProductInstance
    requires :handler, type: ::ProductInstance
    requires :job, type: ::ProductInstance
  end

  def call
    create_cloud_space_id
    create_playbook
    process_playbook
  end

  protected

  def create_cloud_space_id
    return if context.handler.cloud_space_id.present?
    cloud_space_id = context.handler.cloud_resources.get_free_ids(1)[0]
    unless context.handler.update_attributes(cloud_space_id: cloud_space_id)
      context.fail!
    end
  end

  def create_playbook
    return if context.job.playbook_id.present?
    playbook = context.handler.cloud_resources.create_playbook([
      {
        id: context.handler.cloud_space_id,
        type: 'cloud_space',
        state: 'active',
        location_id: context.handler.location_id,
        client_id: context.product_instance.client_id,
        product_id: context.product_instance.product_id,
        product_instance_id: context.product_instance.id,
      }
    ])

    unless context.job.update_attributes(playbook_id: playbook['id'])
      context.fail!
    end
  end

  def process_playbook
    playbook = context.handler.cloud_resources.get_playbook(context.job.playbook_id)
    ActiveRecord::Base.transaction do
      if playbook['state'] == 'failed'
        context.fail! unless context.product_instance.update_attributes(state: 'failed')
        context.fail! unless context.job.update_attributes({
          state: 'failed',
          error_messages: playbook['error_messages'],
        })
      elsif playbook['state'] == 'deployed'
        context.fail! unless context.product_instance.update_attributes(state: 'active')
        context.fail! unless context.job.update_attributes({
          state: 'completed',
          error_messages: [],
        })
        context.fail! unless send_notification_about_product_instance_created
      end
    end
  end

end
