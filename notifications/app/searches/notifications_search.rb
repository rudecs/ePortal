# frozen_string_literal: true

class NotificationsSearch < Searchlight::Search
  def base_query
    Notification
  end

  def search_user_id
    query.where(user_id: user_id)
  end

  def search_with_templates
    query.includes(template: :templates_set)
  end

  def search_delivery_methods
    query.where(delivery_method: delivery_methods)
  end

  def search_unread
    query.unread
  end
end
