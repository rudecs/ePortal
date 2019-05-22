module API
  class V1::PaymentsResource < API::V1
    # helpers API::V1::Helpers

    resource :payments, desc: 'Cписания' do

      helpers do
        def create_params
          declared_params[:payment].merge(gateway: 'robokassa')
        end
      end

      desc 'Пополнение счета'
      params do
        requires :client_id, type: Integer
        requires :payment, type: Hash do
          requires :amount_cents, type: Integer
        end
      end
      post jbuilder: 'payments/create.json' do
        if Rails.env.production?
          authenticate!
          client = current_clients&.find { |c| c['id'] == params[:client_id] }
          error_403! unless current_user.present? && client.present?

          @user = OpenStruct.new(current_user)
          @client = OpenStruct.new(client)
        else
          @client = Client.find(params[:client_id])
          @user = OpenStruct.new(id: 1) # TODO: it won't work anyway in dev cause of validation of user's presence
        end

        @service = Services::Payments::Create.new(create_params, @client, @user.id)
        if @service.call
          @payment = @service.payment
        else
          error_422! @service.payment.errors
        end
      end
    end
  end
end
