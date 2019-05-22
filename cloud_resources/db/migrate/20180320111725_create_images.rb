class CreateImages < ActiveRecord::Migration[5.1]
  def change
    create_table :images do |t|
      t.integer :location_id

      t.integer :cloud_id
      t.string  :cloud_name
      t.string  :cloud_type
      t.string  :cloud_status

      t.integer :partner_id
      t.integer :client_id
      t.integer :product_id
      t.integer :product_instance_id

      t.integer :current_event_id

      t.string :name
      t.string :description
      t.string :state

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
