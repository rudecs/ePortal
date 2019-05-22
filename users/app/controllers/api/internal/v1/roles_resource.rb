class API::Internal::V1::RolesResource < API::Internal::V1

  resource :roles, desc: 'Управление ролями' do

    helpers do
      def search_params
        declared_params[:search]
      end
    end

    desc 'Поиск ролей'
    params do
      optional :search, type: Hash, default: {} do
        optional :ids, type: Array[Integer]
        optional :client_ids, type: Array[Integer]
        optional :user_ids, type: Array[Integer]
        optional :read_only, type: Boolean
        optional :deleted, type: Boolean
        optional :name, type: String
        optional :sort_field, type: String, default: 'id', values: %w[id client_id created_at]
        optional :sort_direction, type: String, values: %w[asc desc], default: 'desc'
      end
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 20
    end
    get jbuilder: 'roles/search.json' do
      @roles = RolesSearch.new(search_params)
        .results
        .page(params[:page])
        .per_page(params[:per_page])
    end

    desc 'Просмотр роли'
    get ':id', jbuilder: 'roles/show.json' do
      @role = Role.find(params[:id])
    end

  end
end
