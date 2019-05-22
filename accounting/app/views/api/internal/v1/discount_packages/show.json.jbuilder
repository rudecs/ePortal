json.(@discount_package, :id, :name)
json.discounts @discount_package.discount_sets do |ds|
  json.(ds, :id, :discount_id, :amount_type)
  json.amount ds.amount.to_f
  json.key_name ds.discount.key_name
end
