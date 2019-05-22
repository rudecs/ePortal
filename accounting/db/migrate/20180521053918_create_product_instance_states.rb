class CreateProductInstanceStates < ActiveRecord::Migration[5.2]
  def change
    create_table :product_instance_states do |t|
      t.integer  :writeoff_id, null: false
      t.integer  :product_id, null: false
      t.integer  :product_instance_id, null: false
      t.jsonb    :billing_data, null: false, default: {}
      t.datetime :start_at, null: false # , limit: 3
      t.datetime :end_at, null: false # , limit: 3

      t.timestamps
    end
    add_index :product_instance_states, :writeoff_id
  end
end
