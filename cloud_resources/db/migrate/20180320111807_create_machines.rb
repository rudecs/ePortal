class CreateMachines < ActiveRecord::Migration[5.1]
  def change
    create_table :machines do |t|
      t.integer :cloud_id
      t.integer :cloud_space_id
      t.integer :image_id

      t.integer :partner_id
      t.integer :client_id
      t.integer :product_id
      t.integer :product_instance_id

      t.integer :current_event_id

      t.string :name
      t.string :description
      t.string :state
      t.string :status

      t.integer :memory
      t.integer :vcpus
      t.integer :boot_disk_size

      t.string :local_ip_address


      t.timestamps
      t.datetime :deleted_at
    end
  end
end
