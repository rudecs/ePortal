# frozen_string_literal: true

module Services
  module SmsAero
    class Base
      attr_reader :notification

      def initialize(notification)
        @notification = notification
      end

      def sms_send
        return false if @notification.delivery_method != 'sms' # && @notification.destination.phone_number?
        data = {
          number: @notification.destination,
          text: @notification.content,
          sign: 'BOODET',
          channel: 'INTERNATIONAL'
          # callbackUrl:
        }
        resp = perform_operation(data, __method__.to_s.split('_').join('/'))
      end

      private

      def perform_operation(data, from_method)
        base_url = Rails.env.production? ? 'https://gate.smsaero.ru' : 'http://localhost:3000'
        conn = Faraday.new(base_url) do |f|
          # f.basic_auth(ENV['SMS_SERVICE_LOGIN'], ENV['SMS_SERVICE_API_KEY'])
          f.basic_auth(Rails.application.secrets.sms_service_login, Rails.application.secrets.sms_service_api_key)
          f.adapter  Faraday.default_adapter
        end
        response = conn.get do |req|
          req.url ['v2', from_method].join('/'), data
          req.headers['Accept'] = 'application/json'
        end
      end
    end
  end
end
