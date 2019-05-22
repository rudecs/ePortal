class API < Grape::API
  format :json

  get :ping do
    status 200
  end

  mount ApiV1 => '/billing/v1'
  mount Internal::V1::Base => '/internal/v1'
end
