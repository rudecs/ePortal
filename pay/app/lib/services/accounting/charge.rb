# frozen_string_literal: true

module Services
  module Accounting
    class Charge
      attr_reader :payment

      def initialize(payment_id)
        @payment = Payment.paid.uncharged.find(payment_id)
      end

      def accounting_charge
        begin
          accounting_request
        rescue
          false
        end
      end

      def charge_payment!
        @payment.charge! unless @payment.charged?
      end

      private

      def accounting_request
        url = accounting_url
        raise 'accounting is not avaliable' unless url

        response = Faraday.post url, {
          payment: {
            puid: @payment.id,
            source: 'payment',
            client_id: @payment.client_id,
            amount: @payment.decorate.formatted_amount,
            currency: @payment.currency,
            payment_method: @payment.decorate.payment_method
          },
          test: true # TODO: remove
        }
        JSON.parse(response.body)
      end

      def accounting_url
        service = Diplomat::Service.get('accounting')
        return false if service&.Address.nil?
        "http://#{service.Address}:#{service.ServicePort}/api/internal/v1/payments"
      end
    end
  end
end
