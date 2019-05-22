class CreateClients < ActiveRecord::Migration[5.1]
  def change
    create_table :clients do |t|
      t.string :name, null: false
      t.string :state, null: false

      t.string :business_entity_type
      t.integer :current_balance_cents, default: 0
      t.string :currency, null: false
      t.string :writeoff_type, null: false
      t.datetime :writeoff_date
      t.integer :writeoff_interval
      t.integer :discount_package_id

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
