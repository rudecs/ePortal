class BillingUnitsGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :billing_units_groups do |t|
      t.string :type, default: 'Charge::ProductInstance', null: false
      t.json :billing_units_group
    end
  end
end
