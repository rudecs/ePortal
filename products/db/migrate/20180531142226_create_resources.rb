class CreateResources < ActiveRecord::Migration[5.1]
  def change
    create_table :resources do |t|
      t.integer :product_instance_id
      t.string :type
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
