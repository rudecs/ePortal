class CreateProductInstances < ActiveRecord::Migration[5.1]
  def change
    create_table :product_instances do |t|

      t.timestamps
    end
  end
end
