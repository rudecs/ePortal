class AddSourceToPayments < ActiveRecord::Migration[5.2]
  def change
    remove_column :payments, :state
    add_column :payments, :puid, :integer, null: false
    add_column :payments, :source, :string, null: false
    add_index :payments, [:puid, :source], unique: true
  end
end
