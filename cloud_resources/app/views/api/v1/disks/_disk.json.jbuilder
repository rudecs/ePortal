if disk.present?
  json.(disk, :id, :machine_id, :partner_id, :client_id, :product_id, :product_instance_id,
              :cloud_id, :cloud_type, :cloud_status,
              :name, :description, :state,
              :size, :iops_sec, :bytes_sec,
              :created_at, :updated_at, :deleted_at)
  json.type 'disk'
  json.disk_type disk.type
end
