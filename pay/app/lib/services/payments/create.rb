# frozen_string_literal: true

module Services
  module Payments
    class Create
      attr_reader :payment

      def initialize(params, client, user_id)
        @payment = Payment.new(params)
        @payment.client_id = client.id
        @payment.user_id = user_id
        @payment.currency = client.currency
      end

      def call
        @payment.save
      end

      def signature
        signature_class.new(@payment).signature
      end

      private

      def signature_class
        case @payment.gateway
        when 'robokassa' then Services::Robokassa::Base
        when 'payu' then Services::Payu::Base
        end
      end
    end
  end
end
