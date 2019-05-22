class API::V1::PaymentsResource < API::V1
  resource :payments, desc: 'Платежи' do

    helpers do
      def create_params
        payment_params = declared_params[:payment].merge({
          source: 'admin',
          currency: 'rub',
        })
        {
          payment: payment_params
        }
      end
    end

    desc 'Пополнение счета'
    params do
      requires :payment, type: Hash do
        # optional :puid, type: Integer # external microservice`s id
        # requires :source, type: String
        requires :client_id, type: Integer
        requires :amount, type: String # decimal
        # requires :currency, type: String
        # requires :payment_method, type: String
      end
    end
    post do
      authenticate!
      proxy = ServiceHttpClient.create('accounting')
      resp = proxy.post("/api/internal/v1/payments", create_params.to_json)
      status resp.status
      JSON.parse resp.body
    end
  end
end
