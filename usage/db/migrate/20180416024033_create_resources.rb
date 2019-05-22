class CreateResources < ActiveRecord::Migration[5.2]
  def change
    create_table :resources do |t|
      t.integer  :ruid, null: false
      t.integer  :product_id, null: false
      t.integer  :product_instance_id, null: false
      t.integer  :client_id, null: false
      t.integer  :partner_id, null: false
      t.string   :kind, null: false
      t.datetime :deleted_at, default: nil
      t.datetime :originally_created_at, limit: 3

      t.timestamps
    end
    add_index :resources, :ruid, unique: true

    add_index :resources, :product_id
    add_index :resources, :product_instance_id
    add_index :resources, :client_id
    add_index :resources, :partner_id
  end
end
