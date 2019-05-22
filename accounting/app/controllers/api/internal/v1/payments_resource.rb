# frozen_string_literal: true

module API
  class Internal::V1::PaymentsResource < Internal::V1
    # helpers API::V1::Helpers

    resource :payments, desc: 'Платежи' do

      helpers do
        def create_params
          declared_params[:payment]
        end
      end

      desc 'Пополнение счета'
      params do
        requires :payment, type: Hash do
          optional :puid, type: Integer # external microservice`s id
          requires :source, type: String
          requires :client_id, type: Integer
          requires :amount, type: String # decimal
          requires :currency, type: String
          # requires :payment_method, type: String
        end
        optional :test, type: Boolean
      end
      post jbuilder: 'payments/create.json' do
        # TODO: remove
        error_403! if params[:test]

        @service = Services::Payments::Create.new(create_params, declared_params&.dig(:payment, :client_id))
        if @service.call
          @payment = @service.payment
          # Client::UnblockJob.perform_later(@service.client.id) and use same as pay_job queue?
          client = @service.client
          if client.blocked?
            # REVIEW: last blocked writeoff amount of halted machines can be lower
            paid_before_block = client.paid_before_block
            # REVIEW: reload client to calc proper balances sum?
            if paid_before_block.present? && client.balances_sum >= paid_before_block.amount
              Services::Clients::Blocker.new(client).unblock!
              client.update_column(:last_threshold_at, nil)
            end
            # REVIEW: paid_before_block.present? = false. == blocked forever?
          end
          @payment
        else
          error_422! @service.payment.errors
        end
      end
    end
  end
end
