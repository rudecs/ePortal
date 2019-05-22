class CreateProductInstances < ActiveRecord::Migration[5.1]
  def change
    create_table :product_instances do |t|
      t.integer :product_id
      t.integer :client_id
      t.integer :playbook_id

      t.string :name
      t.string :state
      t.string :type
      t.json :error_messages

      t.string :handler_price

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
