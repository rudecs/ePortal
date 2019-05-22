class CreatePorts < ActiveRecord::Migration[5.1]
  def change
    create_table :ports do |t|
      t.integer :cloud_space_id
      t.integer :machine_id

      t.integer :cloud_id
      t.string  :cloud_local_ip
      t.integer :cloud_local_port
      t.string  :cloud_protocol
      t.string  :cloud_public_ip
      t.integer :cloud_public_port

      t.integer :partner_id
      t.integer :client_id
      t.integer :product_id
      t.integer :product_instance_id

      t.string :name
      t.string :description
      t.string :state

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
