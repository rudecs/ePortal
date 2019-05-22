class API::Internal::V1::ProductInstances::BulkResource < API::Internal::V1
  resource :product_instances, desc: 'Управление экземплярами продуктов' do
    resource :bulk, desc: 'Массовое управление экземплярами продуктов' do

      helpers do
        def search_params
          declared_params[:search].merge({
            states: 'active',
          })
        end
      end

      desc 'Остановка всех продукт инстансов'
      params do
        requires :search, type: Hash do
          optional :client_ids, type: Array[Integer]
          at_least_one_of :client_ids
        end
      end
      put 'stop' do
        ActiveRecord::Base.transaction do
          product_ids = Product.where(type: 'vm').pluck(:id)
          ProductInstanceSearch.new(search_params.merge(product_ids: product_ids)).results.find_each do |pi|
            context = ::ProductInstance::VM::Stop.call({
              product_instance: pi,
            })
            error_422!(context.errors) if context.failure?
          end
        end

        status 200
      end

    end
  end
end
