class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.decimal :amount, scale: 4, precision: 15, null: false # scale: 2
      t.string  :currency, null: false
      t.integer :client_id, null: false
      t.string  :state, null: false

      t.timestamps
    end
  end
end
