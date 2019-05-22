require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  defaults format: :json do
    scope path: :api do
      scope path: :notifications do
        # /api/:service_name/ping
        get :ping, to: 'service_status#ping'

        mount API::V1 => '/v1'
      end
      scope path: :internal do
        mount API::Internal::V1 => '/v1'
      end
    end
  end
end
