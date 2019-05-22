json.user(@user, :id, :email, :phone, :unconfirmed_phone, :state, :first_name, :last_name, :is_enabled_2fa, :locale,
                 :email_confirmed_at, :email_confirmation_code_expired_at,
                 :phone_confirmed_at, :phone_confirmation_code_expired_at,
                 :created_at, :updated_at, :deleted_at)
json.session(@session, :token, :expired_at, :sms_token_expired_at, :sms_token_confirmed_at)
json.clients [@client] do |client|
  json.(client, :id, :name, :state, :currency, :writeoff_type,
                :created_at, :updated_at, :deleted_at)
end
