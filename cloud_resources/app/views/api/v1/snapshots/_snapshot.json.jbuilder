if snapshot.present?
  json.(snapshot, :id, :machine_id, :partner_id, :client_id, :product_id, :product_instance_id,
                     :cloud_name, :cloud_epoch,
                     # :current_event_id,
                     :name, :description, :state,
                     :created_at, :updated_at, :deleted_at)
   json.type 'snapshot'
end
