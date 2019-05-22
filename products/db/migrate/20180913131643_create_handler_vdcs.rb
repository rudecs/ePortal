class CreateHandlerVdcs < ActiveRecord::Migration[5.1]
  def change
    create_table :handler_vdcs do |t|
      t.integer :product_instance_id, null: false
      t.integer :location_id
      t.integer :cloud_space_id

      t.timestamps
    end
  end
end
