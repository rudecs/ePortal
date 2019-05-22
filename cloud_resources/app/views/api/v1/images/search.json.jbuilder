json.images @images do |image|
  json.(image, :id, :location_id, :partner_id, :client_id, :product_id, :product_instance_id,
               :cloud_id, :cloud_name, :cloud_type, :cloud_status,
               # :current_event_id,
               :name, :description, :state,
               :created_at, :updated_at, :deleted_at)
end

json.total_count @images.count
