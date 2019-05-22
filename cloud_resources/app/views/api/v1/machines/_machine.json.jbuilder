if machine.present?
  json.(machine, :id, :cloud_space_id, :image_id, :partner_id, :client_id, :product_id, :product_instance_id,
                     :cloud_id,
                     :local_ip_address,
                     :memory, :vcpus, :boot_disk_size,
                     # :current_event_id,
                     :name, :description, :state, :status,
                     :created_at, :updated_at, :deleted_at)
   json.type 'machine'
end
