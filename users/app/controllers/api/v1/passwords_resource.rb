class API::V1::PasswordsResource < API::V1
  # helpers API::V1::Helpers

  resource :passwords, desc: 'Управление паролями' do
    helpers do
    end

    desc 'Забыл пароль'
    params do
      requires :password_reset, type: Hash do
        requires :email, type: String, allow_blank: false
      end
    end
    post do
      @user = User.find_by(email: params[:password_reset][:email].downcase)
      error_404! unless @user
      error_422! unless @user.email.present?
      error_403!(email: ['is not confirmed']) unless @user.email_confirmed_at.present?
      code = @user.create_password_reset_code
      error_422! unless code
      @user.send_password_reset_email(code)
      {}
    end

    desc 'Смена пароля по коду'
    params do
      requires :password_reset_code, type: String, allow_blank: false
      requires :password_reset, type: Hash do
        requires :password, type: String, allow_blank: false
        requires :password_confirmation, type: String, allow_blank: false
      end
    end
    post '/reset_password/:password_reset_code' do
      @user = User.reset_password_by_code(declared_params[:password_reset].merge(password_reset_code: params[:password_reset_code]))
      if @user.errors.empty?
        {}
      else
        error_422! @user.errors
      end
    end
  end
end
