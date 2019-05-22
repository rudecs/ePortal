class CreateHandlerVms < ActiveRecord::Migration[5.1]
  def change
    create_table :handler_vms do |t|
      t.integer :product_instance_id, null: false
      t.integer :product_instance_vdc_id
      t.integer :machine_id

      t.timestamps
    end
  end
end
