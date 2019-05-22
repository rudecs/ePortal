class ChangeProductInstances < ActiveRecord::Migration[5.1]
  def change
    change_column_null :product_instances, :current_billing_code_version_id, true
    add_index :product_instances, :current_billing_code_version_id
  end
end
