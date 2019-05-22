if cloud_space.present?
  json.(cloud_space, :id, :location_id, :partner_id, :client_id, :product_id, :product_instance_id,
                     :cloud_id, :cloud_name, :cloud_status,
                     :cloud_public_ip_address,
                     # :current_event_id,
                     :name, :description, :state,
                     :created_at, :updated_at, :deleted_at)
   json.type 'cloud_space'
end
