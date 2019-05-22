class ApiV1 < Grape::API
  format :json

  mount V1::ChargesResource
  mount V1::ProductInstancesResource
end
