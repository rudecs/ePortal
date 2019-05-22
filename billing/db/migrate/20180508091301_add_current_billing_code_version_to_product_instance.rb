class AddCurrentBillingCodeVersionToProductInstance < ActiveRecord::Migration[5.1]
  def change
    add_column :product_instances, :current_billing_code_version_id, :integer, index: true, null: false
    add_timestamps :billing_units_groups
  end
end
