class API::V1::ProductsResource < API::V1
  resource :products, desc: 'Управление продуктами' do

    helpers do
    end

    desc 'Поиск доступных продуктов'
    params do
      optional :search, type: Hash do
      end
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 20
    end
    get do
      proxy = ServiceHttpClient.create('products')
      resp = proxy.get('/api/internal/v1/products.json', declared_params)
      status resp.status
      JSON.parse resp.body
    end

    desc 'Просмотр продукта'
    get ':id' do
      proxy = ServiceHttpClient.create('products')
      resp = proxy.get("/api/internal/v1/products/#{params['id']}.json", declared_params)
      status resp.status
      JSON.parse resp.body
    end
  end
end
