class CreateDiscountSets < ActiveRecord::Migration[5.2]
  def change
    create_table :discount_sets do |t|
      t.integer :discount_id, null: false
      t.integer :discount_package_id, null: false
      t.decimal :amount, scale: 4, precision: 10, null: false
      t.string :amount_type, null: false
      # currency for fixed

      t.timestamps
    end
    add_index :discount_sets, :discount_id
    add_index :discount_sets, :discount_package_id
    add_index :discount_sets, [:discount_id, :discount_package_id], unique: true
  end
end
