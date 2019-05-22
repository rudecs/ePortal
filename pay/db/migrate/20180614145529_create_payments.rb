class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.integer  :amount_cents, null: false
      t.string   :currency, null: false
      t.integer  :client_id, null: false
      t.integer  :user_id, null: false
      t.datetime :paid_at
      t.datetime :charged_at
      t.string   :status
      t.string   :payment_method

      t.timestamps
    end
    add_index :payments, :client_id
    add_index :payments, :user_id
  end
end
