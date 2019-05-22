class API::V1::ClientsResource < API::V1
  # helpers API::V1::Helpers

  resource :clients, desc: 'Управление клиентами' do

    helpers do
    end

    desc 'Список клиентов пользователя'
    params do
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 9999
    end
    get jbuilder: 'clients/index.json' do
      authenticate!
      # current_clients
      # TODO: check subquery
      @clients = Client.joins(roles: :profiles)
                       .where(roles: { profiles: { user_id: current_user['id'] }})
                       .select(
                         <<~SQL
                           clients.*,
                           (
                             SELECT COUNT(profiles.id)
                             FROM roles INNER JOIN profiles ON profiles.role_id = roles.id
                             WHERE roles.client_id = clients.id
                           ) AS users_count
                         SQL
                       )
                       .page(params[:page])
                       .per_page(params[:per_page])
    end

    desc 'Просмотр информации о клиенте'
    params do
      requires :id, type: Integer
    end
    get ':id', jbuilder: 'clients/show.json' do
      authenticate!
      error_403! unless current_clients.pluck('id').include?(params[:id])
      @client = Client.find(params[:id]) # current role in client?
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
    end
    post jbuilder: 'clients/show.json' do
      authenticate!
      error_403! unless current_user.state == 'active'
      @client = Client.new(declared_params[:client].merge(state: 'active'))
      ActiveRecord::Base.transaction do
        error_422!(@client.errors) unless @client.save
        role = Role.create_admin_role(@client)
        Profile.create!(user_id: current_user['id'], role: role)
      end
    end

    desc 'Редактирование клиента'
    params do
      requires :id, type: Integer
      requires :client, type: Hash do
        optional :name, type: String
      end
    end
    put ':id', jbuilder: 'clients/show.json' do
      authenticate!
      error_403! unless current_user.state == 'active'
      error_403! unless current_clients.pluck('id').include?(params[:id])
      @client = Client.find(params[:id])
      error_422!(@client.errors) unless @client.update(declared_params[:client])
    end

    # namespace? + create, update, delete role
    desc 'Список ролей клиента'
    params do
      requires :id, type: Integer
    end
    get ':id/roles', jbuilder: 'clients/roles.json' do
      authenticate!
      error_403! unless current_clients.pluck('id').include?(params[:id])
      @roles = Role.where(client_id: params[:id])
    end

    route_param :client_id, type: Integer do
      resource :users, desc: 'Управление пользователями' do

        # return 404 unless client
        # Так как роль у нас пока только одна, то просматривать могут все пользователи, подключенные к данному клиенту.
        desc 'Список пользователей клиента'
        params do
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 20
        end
        get jbuilder: 'clients/users.json' do
          authenticate!
          error_403! unless current_clients.pluck('id').include?(params[:client_id])
          @users = User.joins(profiles: :role)
                       .where(profiles: { roles: { client_id: params[:client_id] }})
                       .select('users.*, roles.id as role_id, roles.name as role_name') # temp
        end

        desc 'Исключить пользователя или выйти из Клиента'
        params do
          requires :id, type: Integer
        end
        delete ':id' do
          authenticate!
          # TODO: check permissions
          error_403! unless current_clients.pluck('id').include?(params[:client_id])
          error_422!(client: 'should have at least one user') if Role.where(client_id: params[:client_id]).joins(:profiles).size == 1 # TODO: temp solution
          Profile.joins(:role).where(roles: { client_id: params[:client_id] }).find_by!(user_id: params[:id]).destroy
          {}
        end
      end

      resource :invitations, desc: 'Управление приглашениями' do
        desc 'Список приглашений клиента'
        get jbuilder: 'invitations/index.json' do
          authenticate!
          error_403! unless current_clients.pluck('id').include?(params[:client_id])
          @invitations = Invitation.pending.where(client_id: params[:client_id]).includes(:client, :role, :sender, :receiver)
        end

        desc 'Создать приглашение'
        params do
          requires :invitation, type: Hash do
            requires :email, type: String
            requires :role_id, type: Integer
          end
        end
        post jbuilder: 'invitations/show.json' do
          authenticate!
          error_403! unless current_clients.pluck('id').include?(params[:client_id]) # TODO: permissions
          @invitation = Invitation.handle_create_request(declared_params[:invitation].merge(sender_id: current_user['id'], client_id: params[:client_id]))
          error_422!(@invitation.errors) unless @invitation.errors.empty?
        end

        desc 'Удалить приглашение'
        delete ':id' do
          authenticate!
          error_403! unless current_clients.pluck('id').include?(params[:client_id])
          # TODO: pending?
          Invitation.pending.find_by!(id: params[:id], client_id: params[:client_id]).destroy
          {}
        end
      end
    end
  end
end
