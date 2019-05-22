class CreateSnapshots < ActiveRecord::Migration[5.1]
  def change
    create_table :snapshots do |t|
      t.integer :machine_id

      t.integer :partner_id
      t.integer :client_id
      t.integer :product_id
      t.integer :product_instance_id

      t.string :name
      t.string :description
      t.string :state

      t.string :cloud_name
      t.integer :cloud_epoch

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
