class ChangeCharges < ActiveRecord::Migration[5.1]
  def change
    change_table :charges do |t|
      t.integer :resource_id, null: false
      t.integer :client_id, null: false
      t.timestamps
    end

    add_index :charges, :client_id
    add_index :charges, :product_id
    add_index :charges, :resource_id
  end
end
