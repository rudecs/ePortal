class ChangePriceToCharges < ActiveRecord::Migration[5.1]
  def change
    change_column :charges, :price, :numeric, scale: 4
  end
end
