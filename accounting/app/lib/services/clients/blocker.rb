# frozen_string_literal: true

module Services
  module Clients
    class Blocker
      include DeNotifier::Requestable
      attr_reader :target

      def initialize(target)
        @target = target # target == client. name collision in requestable module
      end

      def block!
        request(:put, "/api/internal/v1/clients/#{@target.id}/block.json")
        # to send notification in case of blocking happened
        # TODO: proper amount!
        amount = @target.paid_before_block.amount.to_f.ceil(2)
        DeNotifier::V1::Client.new('accounting').create_notification_request({
          key: :client_blocked,
          client_ids: [@target.id],
          provided_data: {
            recharge_balance_amount: ActionController::Base.helpers.number_to_currency(amount, locale: @target.currency),
          },
        })
      rescue StandardError => e
        $blocker_log.warn { "#block! #{e.message}" }
      end

      def unblock!
        request(:put, "/api/internal/v1/clients/#{@target.id}/unblock.json")
      rescue StandardError => e
        $blocker_log.warn { "#unblock! #{e.message}" }
      end

      protected

      # overwrite DeNotifier::Requestable defaults
      def service
        @service ||= Diplomat::Service.get('users')
      end
    end
  end
end
