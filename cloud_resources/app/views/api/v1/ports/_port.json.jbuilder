if port.present?
  json.(port, :id, :cloud_space_id, :machine_id, :partner_id, :client_id, :product_id, :product_instance_id,
              :cloud_id, :cloud_local_ip, :cloud_local_port, :cloud_protocol, :cloud_public_ip, :cloud_public_port,
              # :current_event_id,
              :name, :description, :state,
              :created_at, :updated_at, :deleted_at)
json.type 'port'
end
