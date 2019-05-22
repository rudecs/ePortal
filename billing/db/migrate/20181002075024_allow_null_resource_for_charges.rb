class AllowNullResourceForCharges < ActiveRecord::Migration[5.1]
  def change
    change_column_null(:charges, :resource_id, true)
  end
end
