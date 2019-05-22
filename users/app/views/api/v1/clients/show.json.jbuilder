json.client do
  json.(@client, :id, :name, :state, :currency,
                 :writeoff_type, :writeoff_date, :writeoff_interval,
                 :business_entity_type, :discount_package_id,
                 :current_balance_cents, :current_bonus_balance_cents,
                 :created_at, :updated_at, :deleted_at)
end
