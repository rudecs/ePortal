class CreateRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :roles do |t|
      t.integer :client_id, null: false
      t.string :name, null: false
      t.boolean :read_only, null: false
      t.hstore :permissions, default: {}

      t.timestamps
      t.datetime :deleted_at
    end

    add_index :roles, :client_id
  end
end
