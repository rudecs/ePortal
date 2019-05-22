module Services
  module Robokassa
    class Result
      attr_reader :payment

      def initialize(params)
        @params = params
        @payment = Payment.unpaid.find(@params['InvId'])
      end

      def valid?
        result_signature == @params['SignatureValue']
      end

      def verify_payment
        save_payment_method
        check_amount
      end

      def response
        ['OK', @payment.id].join
      end

      private

      def save_payment_method
        @payment.update_column :payment_method, @params['PaymentMethod']
      end

      # TODO: currency?
      def check_amount
        received_amount = @params['OutSum'].to_f
        unless received_amount == @payment.amount
          @payment.update_column :amount_cents, (received_amount * 100).to_i
        end
      end

      def result_signature
        Digest::MD5.hexdigest(signature_source).upcase
      end

      # TODO: check
      def signature_source
        [
          @params['OutSum'],
          @payment.id,
          Rails.application.secrets.robokassa&.dig(:robokassa_pass2)
        ].join(':')
      end

    end
  end
end
