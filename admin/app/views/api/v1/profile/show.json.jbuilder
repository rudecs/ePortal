json.user(@current_user, :id, :email, :phone, :unconfirmed_phone, :state, :first_name, :last_name, :is_enabled_2fa,
                 :email_confirmed_at, :email_confirmation_code_expired_at,
                 :phone_confirmed_at, :phone_confirmation_code_expired_at,
                 :created_at, :updated_at, :deleted_at)
json.session(@current_session, :token, :expired_at, :sms_token_expired_at, :sms_token_confirmed_at)
