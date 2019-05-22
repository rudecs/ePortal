if user.present?
  json.(user,
    :id, :state, :locale, :is_enabled_2fa,
    :first_name, :last_name,
    :email, :email_confirmed_at, :email_confirmation_code_expired_at,
    :phone, :phone_confirmed_at, :phone_confirmation_code_expired_at, :unconfirmed_phone,
    :created_at
  )

  json.clients @current_clients do |client|
    json.(client, :id, :name, :state, :currency,
                  :writeoff_type, :writeoff_date, :writeoff_interval,
                  :business_entity_type, :discount_package_id,
                  :current_balance_cents, :current_bonus_balance_cents,
                  :created_at, :updated_at, :deleted_at)
  end

  json.roles @current_roles do |role|
    json.(role, :id, :client_id, :name, :read_only, :permissions)
  end
end
