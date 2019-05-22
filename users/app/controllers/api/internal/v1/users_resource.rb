class API::Internal::V1::UsersResource < API::Internal::V1

  resource :users, desc: 'Управление пользователями' do

    helpers do
      def search_params
        declared_params[:search]
      end
    end

    desc 'Поиск пользователей'
    params do
      optional :search, type: Hash, default: {} do
        optional :id, type: Integer
        optional :ids, type: Array[Integer]
        optional :client_id, type: Integer
        optional :client_ids, type: Array[Integer]
        optional :states, type: Array[String]
        optional :identifier, type: String
        optional :sort_field, type: String, default: 'id', values: %w[id email first_name last_name created_at]
        optional :sort_direction, type: String, values: %w[asc desc], default: 'desc'
      end
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 20
    end
    get jbuilder: 'users/search.json' do
      @users = UserSearch.new(search_params).results.page(params[:page]).per_page(params[:per_page])
    end

    desc 'Просмотр пользователя'
    get ':id', jbuilder: 'users/show.json' do
      @user = User.find(params[:id])
    end

    desc 'Заблокировать пользователя'
    put ':id/block', jbuilder: 'users/show.json' do
      @user = User.find(params[:id])
      unless @user.block
        error_422!(@user.errors)
      end
    end

    desc 'Разблокировать пользователя'
    put ':id/unblock', jbuilder: 'users/show.json' do
      @user = User.find(params[:id])
      unless @user.unblock
        error_422!(@user.errors)
      end
    end

  end
end
