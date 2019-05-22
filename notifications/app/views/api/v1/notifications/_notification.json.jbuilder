if notification.present?
  json.(notification, :id, :delivery_method, :read_at, :created_at, :updated_at)
  json.content  notification.decorate.content
  json.subject  notification.decorate.subject
  json.key_name notification.template&.templates_set&.key_name
end
