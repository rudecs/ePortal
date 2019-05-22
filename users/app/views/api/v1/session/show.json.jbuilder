json.user(@current_user, :id, :email, :phone, :unconfirmed_phone, :state, :first_name, :last_name, :is_enabled_2fa, :locale,
                 :email_confirmed_at, :email_confirmation_code_expired_at,
                 :phone_confirmed_at, :phone_confirmation_code_expired_at,
                 :created_at, :updated_at, :deleted_at)
json.session(@current_session, :token, :expired_at, :sms_token_expired_at, :sms_token_confirmed_at)
json.clients @current_clients do |client|
  json.(client, :id, :name, :state, :currency,
                :writeoff_type, :writeoff_date, :writeoff_interval,
                :business_entity_type, :current_balance_cents, :current_bonus_balance_cents, :discount_package_id,
                :created_at, :updated_at, :deleted_at)
end
json.roles @current_roles do |role|
  json.(role, :id, :client_id, :name, :read_only, :permissions)
end
