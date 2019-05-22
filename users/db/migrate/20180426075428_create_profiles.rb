class CreateProfiles < ActiveRecord::Migration[5.1]
  def change
    create_table :profiles do |t|
      t.integer :role_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end

    add_index :profiles, [:user_id, :role_id], unique: true
  end
end
