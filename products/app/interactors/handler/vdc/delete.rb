class Handler::VDC::Delete < Handler::Base

  params do
    requires :product_instance, type: ::ProductInstance
    requires :handler, type: ::ProductInstance
    requires :job, type: ::ProductInstance
  end

  def call
    if context.handler.cloud_space.present?
      create_playbook
      process_playbook
    else
      # cloud_space does not exist
      # safe delete
      context.fail! unless context.product_instance.update_attributes({
        state: 'deleted',
        deleted_at: Time.now,
      })
      context.fail! unless context.job.update_attributes({
        state: 'completed',
        error_messages: [],
      })
      context.fail! unless send_notification_about_product_instance_deleted
    end
  end

  protected

  def create_playbook
    return if context.job.playbook_id.present?
    playbook = context.handler.cloud_resources.create_playbook([
      {
        id: context.handler.cloud_space_id,
        type: 'cloud_space',
        state: 'deleted',
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
        context.fail! unless context.product_instance.update_attributes({
          state: context.job.action_params['previous_product_instance_state'] || 'active',
        })
        context.fail! unless context.job.update_attributes({
          state: 'failed',
          error_messages: playbook['error_messages'],
        })
      elsif playbook['state'] == 'deployed'
        context.fail! unless context.product_instance.update_attributes({
          state: 'deleted',
          deleted_at: Time.now,
        })
        context.fail! unless context.job.update_attributes({
          state: 'completed',
          error_messages: [],
        })
        context.fail! unless send_notification_about_product_instance_deleted
      end
    end
  end

end
