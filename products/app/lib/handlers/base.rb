class Handlers::Base
  attr_accessor :product_instance, :cloud_resources

  def initialize(product_instance, product_instance_job)
    @cloud_resources = ::CloudResources.new
    @product_instance = product_instance
    @product_instance_job = product_instance_job
  end

  def create
    raise NotImplementedError
  end

  def delete
    active_resources = @product_instance.fetch_resources
    unless active_resources.present?
      @product_instance.update_attributes({
        state: 'deleted',
        error_messages: [],
        deleted_at: Time.now,
      })
      @product_instance_job.update_attributes({
        state: 'completed',
        finished_at: Time.now,
      })
      return
    end

    playbook_schema_elements = active_resources.map do |r|
      {
        id: r['id'],
        type: r['type'],
        state: 'deleted',
      }
    end

    playbook = @cloud_resources.create_playbook(playbook_schema_elements)

    @product_instance.update_attributes({
      state: 'processing',
      playbook_id: playbook['id'],
    })

    @product_instance_job.update_attributes({
      state: 'processing',
    })
  end

  def reload
    return unless @product_instance.playbook_id.present?
    playbook = @cloud_resources.get_playbook(@product_instance.playbook_id)
    playbook['schema'].map do |ele|
      begin
        resource = ::Resource.find_or_create_by({
          id: ele['id'],
          type: ele['type'],
          product_instance_id: @product_instance.id,
        })
      rescue ActiveRecord::RecordNotUnique
        # pass
      end
    end

    if playbook['state'] == 'failed'
      if @product_instance.state == 'creating'
        @product_instance.update_attributes({
          state: 'failed',
          error_messages: playbook['error_messages'],
        })
      elsif @product_instance.state == 'processing'
        @product_instance.update_attributes({
          state: 'active',
          error_messages: playbook['error_messages'],
        })
      end
      @product_instance_job.update_attributes({
        state: 'failed',
        finished_at: Time.now,
      })
    elsif playbook['state'] == 'deployed'
      if @product_instance_job.handler_fn_name == 'delete'
        @product_instance.update_attributes({
          state: 'deleted',
          error_messages: playbook['error_messages'],
          deleted_at: Time.now,
        })
        @product_instance_job.update_attributes({
          state: 'completed',
          finished_at: Time.now,
        })
        ::Notification::Template.send({
          key_name: Notification::Template::KEY_PRODUCT_DELETED,
          client_ids: [@product_instance.client_id],
          provided_data: {
            product_instance_name: @product_instance.name,
          },
        })
      elsif @product_instance_job.handler_fn_name == 'resize'
        @product_instance.update_attributes({
          state: 'active',
          error_messages: playbook['error_messages'],
        })
        @product_instance_job.update_attributes({
          state: 'completed',
          finished_at: Time.now,
        })
        ::Notification::Template.send({
          key_name: Notification::Template::KEY_PRODUCT_RESIZED,
          client_ids: [@product_instance.client_id],
          provided_data: {
            product_instance_id: @product_instance.id,
            product_instance_name: @product_instance.name,
            product_type_id: @product_instance.product.id,
          },
        })
      else
        previous_product_instance_state = @product_instance.state

        # TODO: elsif @product_instance_job.handler_fn_name == 'disable' + 'enable'
        @product_instance.update_attributes({
          state: 'active',
          error_messages: playbook['error_messages'],
        })
        @product_instance_job.update_attributes({
          state: 'completed',
          finished_at: Time.now,
        })
        # update disabled_state = self.state inside soft methods?
        # @product_instance.soft_disable! if @product_instance_job.handler_fn_name == 'disable' && !@product_instance.soft_disabled?
        # @product_instance.soft_restore! if @product_instance_job.handler_fn_name == 'enable'

        if previous_product_instance_state == 'creating'
          ::Notification::Template.send({
            key_name: Notification::Template::KEY_PRODUCT_CREATED,
            client_ids: [@product_instance.client_id],
            provided_data: {
              product_instance_id: @product_instance.id,
              product_instance_name: @product_instance.name,
              product_type_id: @product_instance.product.id,
              product_type_name: @product_instance.product.name,
            },
          })
        end

      end
    elsif %w(pending deploying).include? playbook['state']
      if @product_instance.state != 'processing'
        @product_instance.update_attributes({
          state: 'active',
          error_messages: [],
        })
        @product_instance_job.update_attributes({
          state: 'completed',
          finished_at: Time.now,
        })
      end
    end
  end

  def enable
    raise NotImplementedError
  end

  def disable
    raise NotImplementedError
  end

  protected

end
