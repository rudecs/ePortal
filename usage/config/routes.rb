require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  defaults format: :json do
    namespace :api do
      scope '/usage' do
        namespace :v1 do # /api/:service_name/:version/
          resources :resources, only: :create
          resources :usages, only: :index do
            get 'speed', on: :collection
          end
        end

        # /api/:service_name/ping
        get :ping, to: 'service_status#ping'

        mount Sidekiq::Web => '/sidekiq'
      end
      scope :internal do
        namespace :v1 do
          resources :resources, only: :create
          resources :usages, only: :index do
            get 'speed', on: :collection
          end
        end
      end
    end
  end
end
