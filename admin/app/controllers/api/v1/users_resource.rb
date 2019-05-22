class API::V1::UsersResource < API::V1
  resource :users, desc: 'Управление пользователями' do

    helpers do
    end

    desc 'Поиск пользователей'
    params do
      optional :search, type: Hash do
        optional :ids, type: Array[Integer]
        optional :client_ids, type: Array[Integer]
        optional :states, type: Array[String]
        optional :identifier, type: String
        optional :sort_field, type: String, values: %w[id email first_name last_name created_at]
        optional :sort_direction, type: String, values: %w[asc desc]
      end
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 20
    end
    get do
      proxy = ServiceHttpClient.create('users')
      resp = proxy.get('/api/internal/v1/users.json', declared_params)
      status resp.status
      JSON.parse resp.body
    end

    desc 'Просмотр пользователя'
    get ':id' do
      proxy = ServiceHttpClient.create('users')
      resp = proxy.get("/api/internal/v1/users/#{params['id']}.json", declared_params)
      status resp.status
      JSON.parse resp.body
    end

    desc 'Заблокировать пользователя'
    params do
      requires :id, type: Integer
    end
    put ':id/block' do
      authenticate!
      proxy = ServiceHttpClient.create('users')
      resp = proxy.put("/api/internal/v1/users/#{params[:id]}/block.json", declared_params.to_json)
      status resp.status
      JSON.parse resp.body
    end

    desc 'Разблокировать пользователя'
    params do
      requires :id, type: Integer
    end
    put ':id/unblock' do
      authenticate!
      proxy = ServiceHttpClient.create('users')
      resp = proxy.put("/api/internal/v1/users/#{params[:id]}/unblock.json", declared_params.to_json)
      status resp.status
      JSON.parse resp.body
    end
  end
end
