class CreateDisks < ActiveRecord::Migration[5.1]
  def change
    create_table :disks do |t|
      t.integer :machine_id

      t.integer :cloud_id
      t.string  :cloud_type
      t.string  :cloud_status

      t.integer :partner_id
      t.integer :client_id
      t.integer :product_id
      t.integer :product_instance_id

      t.integer :current_event_id

      t.string  :name
      t.string  :description
      t.string  :type
      t.string  :state
      t.string  :size
      t.string  :iops_sec
      t.string  :bytes_sec

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
