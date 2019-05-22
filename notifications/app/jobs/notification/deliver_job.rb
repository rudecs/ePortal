class Notification::DeliverJob < ApplicationJob
  # queue_as :user_notifications

  # queue_as do
  #   REVIEW: self.arguments.second.nil? ? :default : self.arguments.second.to_sym
  #
  #   video = self.arguments.first
  #   if video.owner.premium?
  #     :premium_videojobs
  #   else
  #     :videojobs
  #   end
  # end

  # TODO: remove logic out of here
  def perform(notification_id, delivery_method)
    notification = Notification.find(notification_id)
    case delivery_method
    when 'sms'
      service_class =
        begin
          ENV['SMS_SERVICE_CLASS']&.classify&.constantize || Services::SmsAero::Base
        rescue NameError
          Services::SmsAero::Base
        end

      service = service_class.new(notification)
      resp = service.sms_send
      # $sms_aero_response_log.info resp
      if resp&.success?
        data = JSON.parse(resp.body)['data']
        # $sms_aero_response_log.info data
        # Might me useful for callback url
        # Partly 0, 1, 2???, 3, 8, 4 are ok?
        # if data.is_a?(Array) && data.any?
        #   status  Статус сообщения (0 — в очереди, 1 — доставлено, 2 — не доставлено, 3 — передано, 8 — на модерации, 6 — сообщение отклонено, 4 — ожидание статуса сообщения)
        #   data.first['status']
        #   notification.delivered!
        # end
        notification.delivered!
      end
      # do smth?
    else
      notification.delivered! if UserMailer.notify(notification).deliver_now
    end
  end
end
