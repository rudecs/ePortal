class CreateDiscountPackages < ActiveRecord::Migration[5.2]
  def change
    create_table :discount_packages do |t|
      t.string :name, null: false, unique: true
      t.text :description

      t.timestamps
    end
  end
end
