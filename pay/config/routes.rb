require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  defaults format: :json do
    scope path: :api do
      scope path: :pay do
        # /api/:service_name/ping
        get :ping, to: 'service_status#ping'

        # === Billing callbacks ===

        # === PayU ===
        # Чтобы сохранить роут в настройках,
        # PayU Russia делает GET запрос на этот же роут.
        # А в процессе работы к нему отправляются только POST запросы.
        # Как быть? Проверять тип запроса и возвращать «true» для
        # тестирующих GET-запросов от PayU, при этом не выполняя для
        # GET больше никакой логики.
        match :payu_ipn, to: 'payu#ipn', via: [:get, :post] # , constraints: Constraints::Payu.new # TODO: handle get request

        # === Robokassa ===
        scope 'robokassa' do
          post :result,  to: 'robokassa#result',  as: :robokassa_result
          get  :success, to: 'robokassa#success', as: :robokassa_success
          get  :fail,    to: 'robokassa#fail',    as: :robokassa_fail
        end

        mount API::V1 => '/v1'
      end
    end
  end
end
