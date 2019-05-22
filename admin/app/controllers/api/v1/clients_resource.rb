class API::V1::ClientsResource < API::V1
  resource :clients, desc: 'Управление клиентами' do

    helpers do
      def search_params
        declared_params[:search]
      end
    end

    desc 'Поиск клиентов'
    params do
      optional :search, type: Hash, default: {} do
        optional :client_ids, type: Array[Integer]
        optional :user_ids, type: Array[Integer]
        optional :states, type: Array[String]
        optional :sort_field, type: String, values: %w[id name created_at]
        optional :sort_direction, type: String, values: %w[asc desc]
      end
      # optional :product_instances_count, type: Boolean, default: false
      # optional :users_count, type: Boolean, default: false
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 20
    end
    get do
      authenticate!
      proxy = ServiceHttpClient.create('users')
      resp = proxy.get("/api/internal/v1/clients", declared_params)
      status resp.status
      JSON.parse resp.body
    end

    desc 'Создание клиента'
    params do
      requires :client, type: Hash do
        requires :name, type: String
        optional :currency, type: String
        optional :writeoff_type, type: String
        optional :writeoff_interval, type: Integer
        optional :business_entity_type, type: String
      end
    end
    post do
      authenticate!
      proxy = ServiceHttpClient.create('users')
      resp = proxy.post("/api/internal/v1/clients", declared_params.to_json)
      status resp.status
      JSON.parse resp.body
    end


    desc 'Просмотр клиента'
    params do
      requires :id, type: Integer
    end
    get ':id' do
      authenticate!
      proxy = ServiceHttpClient.create('users')
      resp = proxy.get("/api/internal/v1/clients/#{params[:id]}.json", declared_params)
      status resp.status
      JSON.parse resp.body
    end

    desc 'Изменение информации о клиенте'
    params do
      requires :id, type: Integer
      requires :client, type: Hash do
        optional :name, type: String
      end
    end
    put ':id' do
      authenticate!
      proxy = ServiceHttpClient.create('users')
      resp = proxy.put("/api/internal/v1/clients/#{params[:id]}.json", declared_params.to_json)
      status resp.status
      JSON.parse resp.body
    end


    desc 'Удаление клиента'
    params do
      requires :id, type: Integer
    end
    delete ':id' do
      authenticate!
      proxy = ServiceHttpClient.create('users')
      resp = proxy.delete("/api/internal/v1/clients/#{params[:id]}.json")
      status resp.status
      JSON.parse resp.body
    end

    desc 'Заблокировать клиента'
    params do
      requires :id, type: Integer
    end
    put ':id/block' do
      authenticate!
      proxy = ServiceHttpClient.create('users')
      resp = proxy.put("/api/internal/v1/clients/#{params[:id]}/block.json", declared_params.to_json)
      status resp.status
      JSON.parse resp.body
    end

    desc 'Разблокировать клиента'
    params do
      requires :id, type: Integer
    end
    put ':id/unblock' do
      authenticate!
      proxy = ServiceHttpClient.create('users')
      resp = proxy.put("/api/internal/v1/clients/#{params[:id]}/unblock.json", declared_params.to_json)
      status resp.status
      JSON.parse resp.body
    end

  end
end
