class AddUniqIndexToWriteoffs < ActiveRecord::Migration[5.2]
  def change
    add_index :writeoffs, [:client_id, :start_date, :end_date], unique: true
    remove_index :payment_transactions, [:subject_type, :subject_id]
    add_index :payment_transactions, [:subject_type, :subject_id], unique: true
  end
end
