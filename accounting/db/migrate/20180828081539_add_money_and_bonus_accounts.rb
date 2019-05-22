class AddMoneyAndBonusAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_transactions, :account_type, :string, null: false, default: 'money'
    remove_index :payment_transactions, [:subject_type, :subject_id]
    add_index :payment_transactions, [:subject_type, :subject_id, :account_type], name: 'subject_on_account_type', unique: true
  end
end
