class CreateDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :discounts do |t|
      t.string :key_name, unique: true

      t.timestamps
    end
  end
end
