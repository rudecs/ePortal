class API::V1::ProfileResource < API::V1
  # helpers API::V1::Helpers

  resource :profile, desc: 'Управление профилем' do
    helpers do
      def update_params
        declared_params[:profile]
      end
    end

    desc 'Просмотр профиля'
    get jbuilder: 'profile/show.json' do
      authenticate!
      @profile = @current_user
    end

    desc 'Редактирование профиля'
    params do
      requires :profile, type: Hash do
        optional :first_name, type: String
        optional :last_name, type: String
        optional :phone, type: String
        optional :locale, type: String
      end
    end
    put jbuilder: 'profile/show.json' do
      authenticate!
      error_422!(@current_user.errors) unless @current_user.update_attributes(update_params)
      @profile = @current_user
    end

    desc 'Подтверждение емайла'
    get '/confirm_email/:email_confirmation_code', jbuilder: 'profile/show.json' do
      @current_user = User.find_by(email_confirmation_code: params[:email_confirmation_code])
      error_404! unless @current_user.present?
      error_422! unless @current_user.email.present?
      error_422!(email: 'already confirmed') if @current_user.email_confirmed_at.present? # add errors to User.new
      error_422! if @current_user.email_confirmation_code_expired_at <= Time.now
      @current_user.email_confirmed_at = Time.now
      unless @current_user.save
        error_422! @current_user.errors
      end

      @profile = @current_user
    end

    desc 'resend confirmation'
    params do
      requires :user, type: Hash do
        optional :email, type: String
        optional :phone, type: String
        # requires :password, type: String
        exactly_one_of :email, :phone
      end
    end
    get '/resend_email_confirmation' do
      email = declared_params[:user][:email]
      @current_user = User.find_by_email(email) if email.present?

      phone = declared_params[:user][:phone]
      @current_user = User.find_by_phone(phone) if phone.present?

      error_404! unless @current_user.present?
      error_422! unless @current_user.email.present?
      error_422! if @current_user.email_confirmed_at.present?
      # REVIEW: error_422! unless @current_user.authenticate(declared_params[:user][:password])
      # generate_email_confirmation_code + save user without validations if email_confirmation_code_expired_at.nil? || (email_confirmation_code_expired_at && email_confirmation_code_expired_at <= 1.hour.from_now)
      # looks bad
      @current_user.generate_email_confirmation_code
      error_422! unless @current_user.save(validate: false)
      @current_user.send_email_confirmation_code
      {}
    end

    desc 'Подтверждение телефона'
    get '/confirm_phone/:phone_confirmation_code', jbuilder: 'profile/show.json' do
      error_401! unless session_token.present?
      @current_session = Session.find_by_token(session_token)
      error_401! unless @current_session.present?
      @current_user = @current_session.user
      error_403! unless @current_user.state == 'active'
      error_403! unless @current_user.email_confirmed_at.present?
      error_422! if @current_user.phone_confirmation_code != params[:phone_confirmation_code] # not secure operation.

      @current_user.confirm_phone

      if @current_user.errors.empty?
        @profile = @current_user
      else
        error_422! @current_user.errors
      end
    end

    desc 'Resend phone confirmation'
    get '/resend_phone_confirmation', jbuilder: 'profile/show.json' do
      error_401! unless session_token.present?
      @current_session = Session.find_by_token(session_token)
      error_401! unless @current_session.present?
      @current_user = @current_session.user
      error_403! unless @current_user.state == 'active'
      error_403! unless @current_user.email_confirmed_at.present?

      # REVIEW: add period, when sms can't be sent
      # like you've recently requested sending confirmation
      # or resend anyway?
      if @current_user.phone_confirmation_period_expired?
        @current_user.resend_phone_confirmation_instructions
      else
        # TODO: refactor
        @current_user.errors.add(:phone_confirmation_code, :not_expired)
      end

      if @current_user.errors.empty?
        @profile = @current_user
      else
        error_422! @current_user.errors
      end
    end

    desc 'Включение двухфакторной аутентификации'
    post '/enable_2fa', jbuilder: 'profile/show.json' do
      authenticate!

      error_422! unless @current_user.phone.present?
      error_422! unless @current_user.phone_confirmed_at.present?

      @current_user.is_enabled_2fa = true
      unless @current_user.save
        error_422! @current_user.errors
      end

      @profile = @current_user
    end

    desc 'Отключение двухфакторной аутентификации'
    post '/disable_2fa', jbuilder: 'profile/show.json' do
      authenticate!

      error_422! unless @current_user.is_enabled_2fa

      ActiveRecord::Base.transaction do
        @current_user.generate_disable_2fa_confirmation_code
        @current_user.send_disable_2fa_confirmation_code
        @current_user.save!
      end

      @profile = @current_user
    end

    desc 'Подтверждение отключения двухфакторной аутентификации'
    post '/confirm_disable_2fa/:sms_code', jbuilder: 'profile/show.json' do
      authenticate!

      error_422! unless @current_user.is_enabled_2fa
      error_422! unless @current_user.disable_2fa_confirmation_code.present?

      unless @current_user.disable_2fa(params[:sms_code])
        error_422! @current_user.errors
      end

      @profile = @current_user
    end

    desc 'Переотправка смс к кодом для отключения двухфакторной аутентификации'
    post '/resend_disable_2fa_confirmation', jbuilder: 'profile/show.json' do
      authenticate!

      if @current_user.disable_2fa_period_expired?
        @current_user.generate_disable_2fa_confirmation_code
        @current_user.send_disable_2fa_confirmation_code
      else
        @current_user.errors.add(:phone_confirmation_code, :not_expired)
      end

      @profile = @current_user
    end
  end
end
