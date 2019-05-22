class CreateWriteoffs < ActiveRecord::Migration[5.2]
  def change
    create_table :writeoffs do |t|
      t.decimal  :amount, scale: 4, precision: 15
      t.decimal  :initial_amount, scale: 4, precision: 15
      t.string   :currency, null: false
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      t.integer  :client_id, null: false
      t.datetime :paid_at
      t.string   :state

      t.timestamps
    end
    add_index :writeoffs, :client_id
  end
end
