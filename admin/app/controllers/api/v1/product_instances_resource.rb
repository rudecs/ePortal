class API::V1::ProductInstancesResource < API::V1
  resource :product_instances, desc: 'Управление экземплярами продуктов' do

    helpers do
      def search_params
        declared_params[:search]
      end
    end

    desc 'Поиск экземпляров продуктов'
    params do
      optional :search, type: Hash, default: {} do
        optional :client_ids, type: Array[Integer]
        optional :product_ids, type: Array[Integer]
        optional :product_types, type: Array[String]
        optional :states, type: Array[String]
        optional :sort_field, type: String, values: %w[id name product_type created_at]
        optional :sort_direction, type: String, values: %w[asc desc]
      end
      optional :no_handler_price, type: Boolean
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 20
    end
    get do
      authenticate!
      proxy = ServiceHttpClient.create('products')
      resp = proxy.get("/api/internal/v1/product_instances.json", declared_params)
      status resp.status
      JSON.parse resp.body
    end

    desc 'Создание экземпляра продукта'
    params do
      requires :product_instance, type: Hash do
        requires :client_id, type: Integer
        requires :product_id, type: Integer
        requires :name, type: String
        optional :description, type: String
        optional :action_params, type: Hash, default: {}
      end
    end
    post do
      authenticate!
      proxy = ServiceHttpClient.create('products')
      resp = proxy.post("/api/internal/v1/product_instances.json", declared_params.to_json)
      status resp.status
      JSON.parse resp.body
    end


    desc 'Просмотр экземпляра продукта'
    params do
      requires :id, type: Integer
    end
    get ':id' do
      authenticate!
      proxy = ServiceHttpClient.create('products')
      resp = proxy.get("/api/internal/v1/product_instances/#{params[:id]}.json", declared_params)
      status resp.status
      JSON.parse resp.body
    end

    desc 'Изменение информации об экземпляре продукта'
    params do
      requires :id, type: Integer
      requires :product_instance, type: Hash do
        optional :name, type: String
      end
    end
    put ':id' do
      authenticate!
      proxy = ServiceHttpClient.create('products')
      resp = proxy.put("/api/internal/v1/product_instances/#{params[:id]}.json", declared_params.to_json)
      status resp.status
      JSON.parse resp.body
    end

    desc 'Управление экземпляром продукта'
    params do
      requires :id, type: Integer
      requires :product_instance, type: Hash do
        requires :action_name, type: String
        optional :action_params, type: Hash, default: {}
      end
    end
    post ':id/manage' do
      authenticate!
      proxy = ServiceHttpClient.create('products')
      resp = proxy.post("/api/internal/v1/product_instances/#{params[:id]}/manage.json", declared_params.to_json)
      status resp.status
      JSON.parse resp.body
    end

    desc 'Удаление экземпляра продукта'
    params do
      requires :id, type: Integer
    end
    delete ':id' do
      authenticate!
      proxy = ServiceHttpClient.create('products')
      resp = proxy.delete("/api/internal/v1/product_instances/#{params[:id]}.json")
      status resp.status
      JSON.parse resp.body
    end

  end
end
