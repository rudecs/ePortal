class API::V1::UsersResource < API::V1
  # helpers API::V1::Helpers

  resource :users, desc: 'Управление пользователями' do

    helpers do
      def create_user_params
        declared_params[:user]
      end
    end

    desc 'Создание пользователя'
    params do
      requires :user, type: Hash do
        optional :email, type: String
        optional :password, type: String
        optional :phone_number, type: String
        at_least_one_of :email, :phone_number
      end
      optional :role_ids, type: Array[Integer]
    end
    post jbuilder: 'users/show.json' do
      ActiveRecord::Base.transaction do
        @user = User.create!(create_user_params)
        if declared_params[:role_ids].present?
          # add user to existing client
        else
          # create client and admin role for user
        end
      end
    end

    desc 'Поиск пользователей'
    params do
    end
    get jbuilder: 'users/search.json' do
    end

    desc 'Просмотр пользователя'
    params do
    end
    get jbuilder: 'users/show.json' do
    end


    desc 'Удаление пользователя'
    delete jbuilder: 'destroy.json' do
    end
  end
end
