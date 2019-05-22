class AddUnconfirmedPhoneToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :unconfirmed_phone, :string
  end
end
