class Handler::Base < BaseInteractor

  def call
  end

  protected

  def send_notification_about_product_instance_created
    ::Notification::Template.send({
      key_name: Notification::Template::KEY_PRODUCT_CREATED,
      client_ids: [context.product_instance.client_id],
      provided_data: {
        product_instance_id: context.product_instance.id,
        product_instance_name: context.product_instance.name,
        product_type_id: context.product_instance.product.id,
        product_type_name: context.product_instance.product.name,
      },
    })
  end

  def send_notification_about_product_instance_deleted
    ::Notification::Template.send({
      key_name: Notification::Template::KEY_PRODUCT_DELETED,
      client_ids: [context.product_instance.client_id],
      provided_data: {
        product_instance_name: context.product_instance.name,
      },
    })
  end

end
