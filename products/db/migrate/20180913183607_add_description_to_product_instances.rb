class AddDescriptionToProductInstances < ActiveRecord::Migration[5.1]
  def change
    unless column_exists? :product_instances, :description
      add_column :product_instances, :description, :string
    end
  end
end
