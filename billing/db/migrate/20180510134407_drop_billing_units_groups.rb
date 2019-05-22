class DropBillingUnitsGroups < ActiveRecord::Migration[5.1]
  def change
    remove_reference :charges, :billing_units_group
    drop_table :billing_units_groups
  end
end
