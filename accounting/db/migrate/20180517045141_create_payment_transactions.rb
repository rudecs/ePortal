class CreatePaymentTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_transactions do |t|
      t.decimal :amount, scale: 4, precision: 15, null: false
      t.string  :currency, null: false
      t.integer :client_id, null: false
      t.string  :subject_type, null: false # null?
      t.integer :subject_id, null: false # null?

      t.timestamps
    end
    add_index :payment_transactions, :client_id
    add_index :payment_transactions, :subject_id
    add_index :payment_transactions, [:subject_type, :subject_id]
  end
end
