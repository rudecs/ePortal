class API::V1::SessionResource < API::V1
  resource :session, desc: 'Управление сессией' do

    desc 'Создание сессии'
    params do
      requires :user, type: Hash do
        optional :email, type: String
        optional :phone, type: String
        requires :password, type: String
        at_least_one_of :email, :phone
      end
    end
    post jbuilder: 'session/show.json' do
      email = declared_params[:user][:email]
      @current_user = User.find_by_email(email) if email.present?

      phone = declared_params[:user][:phone]
      @current_user = User.find_by_phone(phone) if phone.present?

      error_403!(base: ['invalid credentials']) unless @current_user.present?
      error_403!(base: ['invalid credentials']) unless @current_user.authenticate(declared_params[:user][:password])
      error_403!(state: ['is not active']) unless @current_user.state == 'active'
      error_403!(email: ['is not confirmed']) unless @current_user.email_confirmed_at.present?

      @current_session = Session.create!(user: @current_user)
    end

    desc 'Ввод 2FA смс токена'
    params do
      requires :sms_token, type: String
    end
    post '2fa', jbuilder: 'session/show.json' do
      @current_session = Session.find_by_token(session_token)
      error_401! unless @current_session.present?
      error_422! unless @current_session.sms_token.present?
      error_422! if @current_session.sms_token_confirmed_at.present?
      error_422! if @current_session.sms_token_expired_at < Time.now
      error_422! unless declared_params[:sms_token] == @current_session.sms_token

      @current_session.sms_token_confirmed_at = Time.now

      unless @current_session.save
        error_422! @current_session.errors
      end

      @current_user = @current_session.user
    end

    desc 'Переотправка смс токена'
    get '/resend_sms_token' do
      @current_session = Session.find_by_token(session_token)
      error_401! unless @current_session.present?
      error_422! unless @current_session.sms_token.present?
      error_422!(sms_token: ['already confirmed']) if @current_session.sms_token_confirmed_at.present?
      error_422!(sms_token: ['is not expired']) if @current_session.sms_token_expired_at > Time.now

      @current_session.send(:generate_sms_token) # REVIEW: it will actually send notification before validation
      unless @current_session.save
        error_422! @current_session.errors
      end
      {}
    end

    desc 'Аутентификация'
    get jbuilder: 'session/show.json' do
      authenticate!
    end

    desc 'Удаление сессии'
    delete jbuilder: 'destroy.json' do
    end
  end
end
