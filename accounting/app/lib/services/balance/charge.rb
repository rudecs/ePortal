# frozen_string_literal: true

module Services
  module Balance
    class Charge
      attr_reader :payment_transaction

      def initialize(client, amount, options)
        @client = client
        @amount = amount
        @options = options
        @payment_transaction = PaymentTransaction.new(params)
      end

      def call
        # 1 transaction per db
        PaymentTransaction.transaction do
          Client.transaction(requires_new: true) do # (joinable: false, requires_new: true)?
            @payment_transaction.save!
            # Unstable API method +update_balance+ is under review
            @client.update_balance(@payment_transaction.account_type) # REVIEW: payment_transaction will be saved if update_balance does not raise exception. @client.update_column(....)
          end
        end
      rescue
        false
      end

      private

      def params
        {
          client_id: @client.id,
          amount: @amount,
          currency: @options[:subject]&.currency,
          subject: @options[:subject],
          account_type: @options[:account_type]
        }
      end
    end
  end
end

# joinable: false means transactions nested within this transaction will not be discarded (and therefore not be joined to the custom transaction).
# A real nested transaction will be used, or, if the DBMS does not support nested transaction, this behaviour will be
# simulated with Safepoints (this is done for MySQL and Postgres).

# If a custom transaction lives inside another transaction, which we can not control, we can use ActiveRecord::Base.transaction(requires_new: true)
# to force a real (or simulated) nested transaction and avoid joining with the parent transaction.

