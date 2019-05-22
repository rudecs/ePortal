# frozen_string_literal: true

module Services
  module Clients
    class BlockingAlert
      PERIOD = 28.days

      def initialize(time)
        @call_time = time
        @time = time.end_of_hour
        @notifier = DeNotifier::V1::Client.new('accounting')
      end

      def call
        clients.find_each do |client|
          @notifier.create_notification_request({
            key: :blocked_expiration,
            client_ids: [client.id],
            provided_data: {
              days_left: calc_days_left(client)
            },
          })
        end
      end

      private

      def clients
        # WARN: query wprk in postgres
        # blocked in 28days, during this hour
        Client.where.not(blocked_at: nil).active.where(blocked_at: (@time.beginning_of_hour - PERIOD)..@time).where("DATE_PART('hour', blocked_at) = ?", @time.utc.hour)
      end

      def calc_days_left(client)
        ((client.blocked_at + PERIOD - @call_time) / 86_400).to_i # ceil?
      end
    end
  end
end
