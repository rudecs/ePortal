class AddImageNameToResources < ActiveRecord::Migration[5.2]
  def change
    add_column :resources, :image_name, :string
  end
end
