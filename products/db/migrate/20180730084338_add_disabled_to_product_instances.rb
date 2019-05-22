class AddDisabledToProductInstances < ActiveRecord::Migration[5.1]
  def change
    add_column :product_instances, :disabled_at, :datetime
    add_column :product_instances, :disabled_status, :string
  end
end
