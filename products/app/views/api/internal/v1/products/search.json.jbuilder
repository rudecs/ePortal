json.products @products do |product|
  json.(product, :id, :type, :name, :state, :created_at, :updated_at, :deleted_at)
end

json.total_count @products.count
