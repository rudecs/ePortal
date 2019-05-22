json.notifications @notifications do |notification|
  json.partial! 'notifications/notification.json', notification: notification
end

json.total_count @notifications.total_entries
