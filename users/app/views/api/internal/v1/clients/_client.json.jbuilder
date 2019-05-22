if client.present?
  json.(client, :id, :name, :state, :created_at, :users_count, :current_balance_cents, :current_bonus_balance_cents)
end
