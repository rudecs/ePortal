class NotificationsRequest::ProcessJob < ApplicationJob
  # queue_as :smth
  def perform(request_id)
    req = NotificationsRequest.find(request_id)
    # TODO: handle pagination
    notifications = Services::Notifications::Create.new(req).call
    notifications.each do |n|
      Notification::DeliverJob.perform_later(n.first, n.last)
    end if notifications
    # retry?
  end
end
