require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope path: :api do
    scope path: :internal do
      mount API::Internal::V1 => '/v1'
    end
    scope path: :products do
      mount API::V1 => '/v1'
      mount Sidekiq::Web => '/sidekiq'
    end
  end
end
