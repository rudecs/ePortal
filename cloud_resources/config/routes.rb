require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do

  scope path: :api do
    scope path: :internal do
      mount API::Internal::V1 => '/v1'
    end
    scope path: :resources do
      mount API::V1 => '/v1'
      mount Sidekiq::Web => '/sidekiq'
    end
  end
end
