class API::Internal::V1::ProductsResource < API::Internal::V1
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
    get jbuilder: 'products/search.json' do
      @products = Product.where(state: 'active', deleted_at: nil)
    end

    desc 'Просмотр продукта'
    get ':id', jbuilder: 'products/show.json' do
      @product = Product.find(params[:id])
    end
  end
end
