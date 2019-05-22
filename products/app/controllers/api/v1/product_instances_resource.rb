class API::V1::ProductInstancesResource < API::V1
  # helpers API::V1::Helpers

  resource :product_instances, desc: 'Управление экземплярами продуктов' do

    helpers do
      def search_params
        declared_params[:search].merge({
          client_ids: current_clients.pluck('id'),
        })
      end

      def create_vdc_params
        result = declared_params[:product_instance].merge(declared_params[:product_instance][:action_params])
        result.delete(:action_params)
        result
      end

      def create_vm_params
        result = declared_params[:product_instance].merge(declared_params[:product_instance][:action_params])
        result.delete(:action_params)
        result
      end

      def update_params
        declared_params[:product_instance]
      end

      def manage_params
        result = declared_params[:product_instance].merge(declared_params[:product_instance][:action_params])
        result[:product] = @product
        result[:product_instance] = @product_instance
        result.delete(:action_params)
        result
      end

      def find_current_client(id)
        current_clients.find {|client| client['id'] == id }
      end
    end

    desc 'Поиск экземпляров продуктов'
    params do
      optional :search, type: Hash, default: {} do
        optional :states, type: Array[String], values: ProductInstance::STATES
        optional :product_ids, type: Array[Integer]
        optional :product_types, type: Array[String]
        optional :name, type: String
        optional :sort_field, type: String, default: 'id', values: %w[id name product_type created_at]
        optional :sort_direction, type: String, values: %w[asc desc], default: 'desc'
      end
      optional :no_handler_price, type: Boolean, default: false
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 20
    end
    get jbuilder: 'product_instances/search.json' do
      authenticate!
      @no_handler_price = params[:no_handler_price]
      @product_instances = ProductInstanceSearch.new(search_params)
                                                .results
                                                .page(params[:page])
                                                .per_page(params[:per_page])
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
    post jbuilder: 'product_instances/show.json' do
      authenticate!

      client = find_current_client(declared_params[:product_instance][:client_id])
      error_403! if client.nil?
      error_403! if client['state'] != 'active'

      @product = Product.find(declared_params[:product_instance][:product_id])
      if @product.type == 'vdc'
        context = ::ProductInstance::VDC::Create.call(create_vdc_params)
      elsif @product.type == 'vm'
        context = ::ProductInstance::VM::Create.call(create_vm_params)
      end

      error_422!(context.errors) if context.failure?

      @product_instance = context.product_instance
    end


    desc 'Просмотр экземпляра продукта'
    params do
      requires :id, type: Integer
    end
    get ':id', jbuilder: 'product_instances/show.json' do
      authenticate!
      @product_instance = ProductInstance.find_by({
        id: params[:id],
        client_id: current_clients.pluck('id')
      })
    end

    desc 'Изменение информации об экземпляре продукта'
    params do
      requires :id, type: Integer
      requires :product_instance, type: Hash do
        optional :name, type: String
      end
    end
    put ':id', jbuilder: 'product_instances/show.json' do
      authenticate!

      @product_instance = ProductInstance.find_by({
        id: params[:id],
        client_id: current_clients.pluck('id')
      })

      unless @product_instance.update_attributes(update_params)
        error_422! @product_instance.errors
      end
    end

    desc 'Управление экземпляром продукта'
    params do
      requires :id, type: Integer
      requires :product_instance, type: Hash do
        requires :action_name, type: String
        optional :action_params, type: Hash, default: {}
      end
    end
    post ':id/manage', jbuilder: 'product_instances/show.json' do
      authenticate!

      @product_instance = ProductInstance.find(params[:id])
      client = find_current_client(@product_instance.client_id)
      error_403! if client.nil?
      error_402! if client['state'] == 'blocked'
      error_403! if client['state'] != 'active'

      action_name = declared_params[:product_instance][:action_name].camelcase

      @product = @product_instance.product
      if @product.type == 'vdc'
        interactor = "::ProductInstance::VDC::#{action_name}".constantize
      elsif @product.type == 'vm'
        interactor = "::ProductInstance::VM::#{action_name}".constantize
      end

      context = interactor.call(manage_params)
      error_422!(context.errors) if context.failure?
      @product_instance = context.product_instance.reload
      @product_instance_job = context.job.reload
    end

    desc 'Удаление экземпляра продукта'
    params do
      requires :id, type: Integer
    end
    delete ':id', jbuilder: 'product_instances/show.json' do
      authenticate!

      @product_instance = ProductInstance.find(params[:id])
      client = find_current_client(@product_instance.client_id)
      error_403! if client.nil?
      error_402! if client['state'] == 'blocked'
      error_403! if client['state'] != 'active'

      @product = @product_instance.product
      if @product.type == 'vdc'
        interactor = "::ProductInstance::VDC::Delete".constantize
      elsif @product.type == 'vm'
        interactor = "::ProductInstance::VM::Delete".constantize
      end

      context = interactor.call(product_instance: @product_instance)
      error_422!(context.errors) if context.failure?
      @product_instance = context.product_instance.reload
      @product_instance_job = context.job.reload
    end

  end
end
