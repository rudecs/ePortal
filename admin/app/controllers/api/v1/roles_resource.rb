class API::V1::RolesResource < API::V1
  resource :roles, desc: 'Управление ролями' do

    helpers do
    end

    desc 'Поиск ролей'
    params do
      optional :search, type: Hash do
        optional :ids, type: Array[Integer]
        optional :client_ids, type: Array[Integer]
        optional :user_ids, type: Array[Integer]
        optional :read_only, type: Boolean
        optional :deleted, type: Boolean
        optional :name, type: String
        optional :sort_field, type: String, values: %w[id client_id created_at]
        optional :sort_direction, type: String, values: %w[asc desc]
      end
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 20
    end
    get do
      proxy = ServiceHttpClient.create('users')
      resp = proxy.get('/api/internal/v1/roles.json', declared_params)
      status resp.status
      JSON.parse resp.body
    end

    desc 'Просмотр роли'
    get ':id' do
      proxy = ServiceHttpClient.create('users')
      resp = proxy.get("/api/internal/v1/roles/#{params['id']}.json", declared_params)
      status resp.status
      JSON.parse resp.body
    end
  end
end
