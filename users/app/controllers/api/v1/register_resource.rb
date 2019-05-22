class API::V1::RegisterResource < API::V1
  # helpers API::V1::Helpers

  resource :register, desc: 'Регистрация пользователя' do

    helpers do
      def create_client_params
        declared_params[:client].merge({
          state: 'active',
        })
      end
      def create_user_params
        declared_params[:user].merge({
          state: 'active',
          is_enabled_2fa: false,
        })
      end
    end

    desc 'Регистрация пользователя'
    params do
      requires :user, type: Hash do
        optional :email, type: String
        optional :phone, type: String
        requires :password, type: String
        at_least_one_of :email, :phone
        optional :first_name, type: String
        optional :last_name, type: String
        optional :locale, type: String
      end
      requires :client, type: Hash do
        optional :name, type: String, default: 'No Name'
        optional :currency, type: String, values: Client::CURRENCIES, default: 'rub'
        optional :writeoff_type, type: String, values: Client::WRITEOFF_TYPES, default: 'prepaid'
        optional :writeoff_interval, type: Integer, values: Client::WRITEOFF_INTERVALS, default: 0
        optional :business_entity_type, type: String, values: Client::BUSINESS_ENTITY_TYPES, default: 'individual'
      end
      optional :invitation_token, type: String
    end
    post jbuilder: 'register.json' do
      service = Services::Users::Registration.new(
        {
          user:   create_user_params,
          client: create_client_params
        },
        params[:invitation_token]
      )

      error_404!(invitation: 'not found. Perhaps it has expired or has been deleted.') if service.token_but_blank_invitation? # TODO: internalization
      error_422!(service.user.errors) unless service.register

      @user = service.user
      @session = service.session
      @client = service.client
      # not used in view
      # @role = service.role
      # @profile = service.profile

      # charge bonus account
      service.add_bonuses
    end

    desc 'Удаление пользователя'
    delete jbuilder: 'destroy.json' do
    end
  end
end
