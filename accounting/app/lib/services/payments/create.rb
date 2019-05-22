# frozen_string_literal: true

module Services
  module Payments
    class Create
      attr_reader :payment, :client

      def initialize(params, client_id)
        @params = params
        @client = Client.find(client_id)
        # @payment = Payment.new(params)
        puid_nextval! if @params[:source] == 'admin'
        @payment = Payment.where(puid: @params[:puid], source: @params[:source]).first_or_initialize(@params)
        @payment.client = @client
      end

      def call
        # REVIEW: flow
        Payment.transaction do
          Client.transaction(requires_new: true) do
            @payment.save!
            @client.charge(
              @payment.amount,
              {
                subject: @payment,
                account_type: @payment.source == 'payment' ? 'money' : 'bonus'
              }
            )
          end
        end if @payment.new_record?
        true
      rescue
        false
      end

      def puid_nextval!
        query = "SELECT nextval('admin_payment_puid_sequence')"
        id = ActiveRecord::Base.connection.exec_query(query)[0]['nextval']
        @params.merge!(puid: id)
      end
    end
  end
end
