json.profile do
  json.id    @profile.id
  json.first_name @profile.first_name
  json.last_name @profile.last_name
  json.state @profile.state
  json.locale @profile.locale

  json.email                              @profile.email
  json.email_confirmed_at                 @profile.email_confirmed_at
  json.email_confirmation_code_expired_at @profile.email_confirmation_code_expired_at
  json.phone                              @profile.phone
  json.phone_confirmed_at                 @profile.phone_confirmed_at
  json.phone_confirmation_code_expired_at @profile.phone_confirmation_code_expired_at
  json.unconfirmed_phone                  @profile.unconfirmed_phone
  json.is_enabled_2fa                     @profile.is_enabled_2fa

  json.clients @current_clients do |client|
    json.(client, :id, :name, :state, :currency,
                  :writeoff_type, :writeoff_date, :writeoff_interval,
                  :business_entity_type, :discount_package_id,
                  :current_balance_cents, :current_bonus_balance_cents,
                  :created_at, :updated_at, :deleted_at)
  end if @current_clients.present?

  json.roles @current_roles do |role|
    json.(role, :id, :client_id, :name, :read_only, :permissions)
  end if @current_roles.present?

end
