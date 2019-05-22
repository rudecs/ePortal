class CreateCharges < ActiveRecord::Migration[5.1]
  def change
    create_table :charges do |t|
      t.string :type, null: false
      t.integer :product_id
      t.references :billing_units_group, foreign_key: true, null: false
      t.string :key, null: false
      t.float :count, null: false
      t.money :price, null: false
      t.string :currency, null: false
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
    end
  end
end
