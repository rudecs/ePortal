class API::Internal::V1::ClientsResource < API::Internal::V1

  resource :clients, desc: 'Управление клиентами' do

    helpers do
      def search_params
        declared_params[:search]
      end
    end

    desc 'Поиск клиентов'
    params do
      optional :search, type: Hash, default: {} do
        optional :ids, type: Array[Integer]
        optional :user_ids, type: Array[Integer]
        optional :states, type: Array[String], values: Client::STATES

        optional :name, type: String
        optional :business_entity_type, type: String
        # optional :current_balance_cents, type: Boolean # negative
        # optional :current_bonus_balance_cents,type:
        # total_balance
        optional :currency, type: String, values: Client::CURRENCIES
        optional :writeoff_type, type: String, values: Client::WRITEOFF_TYPES
        # optional :writeoff_date, type: DateTime
        optional :writeoff_interval, type: Integer, values: Client::WRITEOFF_INTERVALS
        optional :discount_package_id, type: Integer
        optional :deleted, type: Boolean
        # optional :deleted_at, type: DateTime # Boolean deleted
        optional :sort_field, type: String, default: 'id', values: %w[id name created_at users_count state]
        optional :sort_direction, type: String, values: %w[asc desc], default: 'desc'
      end
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 20
    end
    get jbuilder: 'clients/search.json' do
      @clients = ClientsSearch.new(search_params.merge(users_counter: true))
                              .results
                              .page(params[:page])
                              .per_page(params[:per_page])
    end

    desc 'Просмотр клиента'
    get ':id', jbuilder: 'clients/show.json' do
      @client = Client.find(params[:id])
    end

    desc 'Создать клиента'
    params do
      requires :client, type: Hash do
        requires :name, type: String
        optional :currency, type: String, values: Client::CURRENCIES, default: 'rub'
        optional :writeoff_type, type: String, values: Client::WRITEOFF_TYPES, default: 'prepaid'
        optional :writeoff_interval, type: Integer, values: Client::WRITEOFF_INTERVALS, default: 0
        optional :business_entity_type, type: String, values: Client::BUSINESS_ENTITY_TYPES, default: 'individual'
      end
      requires :user_id, type: Integer
    end
    post jbuilder: 'clients/show.json' do
      @client = Client.new(declared_params[:client].merge(state: 'active'))
      ActiveRecord::Base.transaction do
        error_422!(@client.errors) unless @client.save
        role = Role.create_admin_role(@client)
        Profile.create!(user_id: params[:user_id], role: role)
      end
    end

    desc 'Изменить клиента'
    params do
      requires :id, type: Integer
      requires :client, type: Hash do
        optional :name, type: String
        optional :writeoff_type, type: String, values: Client::WRITEOFF_TYPES
        optional :writeoff_interval, type: Integer, values: Client::WRITEOFF_INTERVALS
        optional :business_entity_type, type: String, values: Client::BUSINESS_ENTITY_TYPES
      end
    end
    put ':id', jbuilder: 'clients/show.json' do
      @client = Client.find(params[:id])
      error_422!(@client.errors) unless @client.update(declared_params[:client])
    end

    desc 'Отключить клиента'
    delete ':id' do
      Client.find(params[:id]).delete
      {}
    end

    desc 'Заблокировать клиента'
    put ':id/block', jbuilder: 'clients/show.json' do
      @client = Client.find(params[:id])

      unless @client.block
        error_422!(@client.errors)
      end

      proxy = ServiceHttpClient.create('products')
      resp = proxy.put("/api/internal/v1/product_instances/bulk/stop.json", {
        search: {
          client_ids: params[:id]
        }
      }.to_json)

      if resp.status != 200
        # TODO отправить сообщение админу об ошибке
      end
    end

    desc 'Разблокировать клиента'
    put ':id/unblock', jbuilder: 'clients/show.json' do
      @client = Client.find(params[:id])
      unless @client.unblock
        error_422!(@client.errors)
      end
    end

    # REVIEW: soft_restore?
  end
end
